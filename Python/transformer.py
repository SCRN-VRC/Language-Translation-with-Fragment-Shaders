#python==3.8.6/tensorflow==2.5.0/keras==2.4.3/sklearn

from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences
from random import randint
import tensorflow as tf
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from sklearn.utils import shuffle
import time
import collections
import struct
import os

def tokenize(x):
    """
    Tokenize x
    :param x: List of sentences/strings to be tokenized
    :return: Tuple of (tokenized x data, tokenizer used to tokenize x)
    """
    tokenizer=Tokenizer()
    tokenizer.fit_on_texts(x)
    t=tokenizer.texts_to_sequences(x)
    # TODO: Implement
    return t, tokenizer

def pad(x, length=None):
    """
    Pad x
    :param x: List of sequences.
    :param length: Length to pad the sequence to.  If None, use length of longest sequence in x.
    :return: Padded numpy array of sequences
    """
    # TODO: Implement
    padding=pad_sequences(x,padding='post',maxlen=length)
    return padding

def preprocess_input(df):
    sentences = []
    for i in df:
        sentences.append("<SOS> " + i + " <EOS>")
    text_tokenized, text_tokenizer = tokenize(sentences)
    text_pad = pad(text_tokenized)
    return text_pad, text_tokenizer, sentences

def get_angles(pos, i, d_model):
    angle_rates = 1 / np.power(10000, (2 * (i//2)) / np.float32(d_model))
    return pos * angle_rates

def positional_encoding(position, d_model):
    angle_rads = get_angles(np.arange(position)[:, np.newaxis],
                          np.arange(d_model)[np.newaxis, :],
                          d_model)
    # apply sin to even indices in the array; 2i
    angle_rads[:, 0::2] = np.sin(angle_rads[:, 0::2])
    # apply cos to odd indices in the array; 2i+1
    angle_rads[:, 1::2] = np.cos(angle_rads[:, 1::2])
    pos_encoding = angle_rads[np.newaxis, ...]
    return tf.cast(pos_encoding, dtype=tf.float32)

def create_padding_mask(seq):
    seq = tf.cast(tf.math.equal(seq, 0), tf.float32)

    # add extra dimensions to add the padding
    # to the attention logits.
    return seq[:, tf.newaxis, tf.newaxis, :]  # (batch_size, 1, 1, seq_len)

def create_look_ahead_mask(size):
    mask = 1 - tf.linalg.band_part(tf.ones((size, size)), -1, 0)
    return mask  # (seq_len, seq_len)

def scaled_dot_product_attention(q, k, v, mask, outputs, name):
    """Calculate the attention weights.
    q, k, v must have matching leading dimensions.
    k, v must have matching penultimate dimension, i.e.: seq_len_k = seq_len_v.
    The mask has different shapes depending on its type(padding or look ahead)
    but it must be broadcastable for addition.

    Args:
      q: query shape == (..., seq_len_q, depth)
      k: key shape == (..., seq_len_k, depth)
      v: value shape == (..., seq_len_v, depth_v)
      mask: Float tensor with shape broadcastable
            to (..., seq_len_q, seq_len_k). Defaults to None.

    Returns:
      output, attention_weights
    """

    matmul_qk = tf.matmul(q, k, transpose_b=True)  # (..., seq_len_q, seq_len_k)
    outputs[f'{name}_sat_matmul_qk'] = matmul_qk.numpy()
    
    # scale matmul_qk
    dk = tf.cast(tf.shape(k)[-1], tf.float32)
    scaled_attention_logits = matmul_qk / tf.math.sqrt(dk)
    outputs[f'{name}_sat_logits'] = scaled_attention_logits.numpy()
    
    # add the mask to the scaled tensor.
    if mask is not None:
        scaled_attention_logits += (mask * -1e9)

    outputs[f'{name}_sat_mask'] = scaled_attention_logits.numpy()
    # softmax is normalized on the last axis (seq_len_k) so that the scores
    # add up to 1.
    attention_weights = tf.nn.softmax(scaled_attention_logits, axis=-1)  # (..., seq_len_q, seq_len_k)
    outputs[f'{name}_sat_softmax'] = attention_weights.numpy()
    
    output = tf.matmul(attention_weights, v)  # (..., seq_len_q, depth_v)
    outputs[f'{name}_sat_matmul_atten'] = output.numpy()
    
    return output, attention_weights

class MultiHeadAttention(tf.keras.layers.Layer):
    def __init__(self, d_model, num_heads):
        super(MultiHeadAttention, self).__init__()
        self.num_heads = num_heads
        self.d_model = d_model

        assert d_model % self.num_heads == 0

        self.depth = d_model // self.num_heads

        self.wq = tf.keras.layers.Dense(d_model)
        self.wk = tf.keras.layers.Dense(d_model)
        self.wv = tf.keras.layers.Dense(d_model)

        self.dense = tf.keras.layers.Dense(d_model)

    def split_heads(self, x, batch_size):
        """Split the last dimension into (num_heads, depth).
        Transpose the result such that the shape is (batch_size, num_heads, seq_len, depth)
        """
        x = tf.reshape(x, (batch_size, -1, self.num_heads, self.depth))
        return tf.transpose(x, perm=[0, 2, 1, 3])

    def call(self, v, k, q, mask, name):
        outputs = {}
        batch_size = tf.shape(q)[0]

        q = self.wq(q)  # (batch_size, seq_len, d_model)
        outputs[f'{name}_q'] = q.numpy()
        k = self.wk(k)  # (batch_size, seq_len, d_model)
        outputs[f'{name}_k'] = k.numpy()
        v = self.wv(v)  # (batch_size, seq_len, d_model)
        outputs[f'{name}_v'] = v.numpy()

        q = self.split_heads(q, batch_size)  # (batch_size, num_heads, seq_len_q, depth)
        outputs[f'{name}_q_split_heads'] = q.numpy()
        k = self.split_heads(k, batch_size)  # (batch_size, num_heads, seq_len_k, depth)
        outputs[f'{name}_k_split_heads'] = k.numpy()
        v = self.split_heads(v, batch_size)  # (batch_size, num_heads, seq_len_v, depth)
        outputs[f'{name}_v_split_heads'] = v.numpy()

        # scaled_attention.shape == (batch_size, num_heads, seq_len_q, depth)
        # attention_weights.shape == (batch_size, num_heads, seq_len_q, seq_len_k)
        scaled_attention, attention_weights = scaled_dot_product_attention(
            q, k, v, mask, outputs, name)

        scaled_attention = tf.transpose(scaled_attention, perm=[0, 2, 1, 3])  # (batch_size, seq_len_q, num_heads, depth)
        outputs[f'{name}_scaled_attention_transpose'] = scaled_attention.numpy()

        concat_attention = tf.reshape(scaled_attention,
                                      (batch_size, -1, self.d_model))  # (batch_size, seq_len_q, d_model)
        outputs[f'{name}_concat_attention'] = concat_attention.numpy()

        output = self.dense(concat_attention)  # (batch_size, seq_len_q, d_model)
        outputs[f'{name}_mha_output_dense'] = output.numpy()

        return output, attention_weights, outputs

def point_wise_feed_forward_network(d_model, dff):
    return tf.keras.Sequential([
        tf.keras.layers.Dense(dff, activation='relu'),  # (batch_size, seq_len, dff)
        tf.keras.layers.Dense(d_model)  # (batch_size, seq_len, d_model)
    ])

class EncoderLayer(tf.keras.layers.Layer):
    def __init__(self, d_model, num_heads, dff, rate=0.1):
        super(EncoderLayer, self).__init__()

        self.mha = MultiHeadAttention(d_model, num_heads)
        self.ffn = point_wise_feed_forward_network(d_model, dff)

        self.layernorm1 = tf.keras.layers.LayerNormalization(epsilon=1e-6)
        self.layernorm2 = tf.keras.layers.LayerNormalization(epsilon=1e-6)

        self.dropout1 = tf.keras.layers.Dropout(rate)
        self.dropout2 = tf.keras.layers.Dropout(rate)

    def call(self, x, training, mask, i):
        outputs = {}

        attn_output, _, mha_out = self.mha(x, x, x, mask, f'encoder_layer{i+1}')  # (batch_size, input_seq_len, d_model)
        attn_output = self.dropout1(attn_output, training=training)
        outputs.update(mha_out)

        out1 = self.layernorm1(x + attn_output)  # (batch_size, input_seq_len, d_model) , residual conection
        outputs[f'encoder_layer{i+1}_normalize1'] = out1.numpy()

        ffn_output = self.ffn(out1)  # (batch_size, input_seq_len, d_model)
        ffn_output = self.dropout2(ffn_output, training=training)
        outputs[f'encoder_layer{i+1}_ffn'] = ffn_output.numpy()

        out2 = self.layernorm2(out1 + ffn_output)  # (batch_size, input_seq_len, d_model)
        outputs[f'encoder_layer{i+1}_normalize2'] = out2.numpy()

        return out2, outputs

class DecoderLayer(tf.keras.layers.Layer):
    def __init__(self, d_model, num_heads, dff, rate=0.1):
        super(DecoderLayer, self).__init__()

        self.mha1 = MultiHeadAttention(d_model, num_heads)
        self.mha2 = MultiHeadAttention(d_model, num_heads)

        self.ffn = point_wise_feed_forward_network(d_model, dff)

        self.layernorm1 = tf.keras.layers.LayerNormalization(epsilon=1e-6)
        self.layernorm2 = tf.keras.layers.LayerNormalization(epsilon=1e-6)
        self.layernorm3 = tf.keras.layers.LayerNormalization(epsilon=1e-6)

        self.dropout1 = tf.keras.layers.Dropout(rate)
        self.dropout2 = tf.keras.layers.Dropout(rate)
        self.dropout3 = tf.keras.layers.Dropout(rate)

    def call(self, x, enc_output, training,
             look_ahead_mask, padding_mask, i):
        # enc_output.shape == (batch_size, input_seq_len, d_model)
        outputs = {}

        attn1, attn_weights_block1, mha_out = self.mha1(x, x, x, look_ahead_mask,
                                                        f'decoder_layer{i+1}_1')  # (batch_size, target_seq_len, d_model)
        attn1 = self.dropout1(attn1, training=training)
        outputs.update(mha_out)

        out1 = self.layernorm1(attn1 + x)
        outputs[f'decoder_layer{i+1}_normalize1'] = out1.numpy()

        attn2, attn_weights_block2, mha_out2 = self.mha2(
            enc_output, enc_output, out1, padding_mask, f'decoder_layer{i+1}_2')  # (batch_size, target_seq_len, d_model)
        attn2 = self.dropout2(attn2, training=training)
        outputs.update(mha_out2)

        out2 = self.layernorm2(attn2 + out1)  # (batch_size, target_seq_len, d_model)
        outputs[f'decoder_layer{i+1}_normalize2'] = out2.numpy()

        ffn_output = self.ffn(out2)  # (batch_size, target_seq_len, d_model)
        ffn_output = self.dropout3(ffn_output, training=training)
        outputs[f'decoder_layer{i+1}_ffn'] = ffn_output.numpy()

        out3 = self.layernorm3(ffn_output + out2)  # (batch_size, target_seq_len, d_model)
        outputs[f'decoder_layer{i+1}_ffn_norm'] = out3.numpy()

        return out3, attn_weights_block1, attn_weights_block2, outputs

class Encoder(tf.keras.layers.Layer):
    def __init__(self, num_layers, d_model, num_heads, dff, input_vocab_size,
                 maximum_position_encoding, rate=0.1):
        super(Encoder, self).__init__()

        self.d_model = d_model
        self.num_layers = num_layers

        self.embedding = tf.keras.layers.Embedding(input_vocab_size, d_model)
        self.pos_encoding = positional_encoding(maximum_position_encoding,
                                                self.d_model)

        self.enc_layers = [EncoderLayer(d_model, num_heads, dff, rate)
                           for _ in range(num_layers)]

        self.dropout = tf.keras.layers.Dropout(rate)

    def call(self, x, training, mask):
        outputs = {}

        seq_len = tf.shape(x)[1]

        # adding embedding and position encoding.
        x = self.embedding(x)  # (batch_size, input_seq_len, d_model)
        outputs['encoder_layer_embedding'] = x.numpy()

        x *= tf.math.sqrt(tf.cast(self.d_model, tf.float32))
        outputs['encoder_layer_multiply_sqrt'] = x.numpy()

        x += self.pos_encoding[:, :seq_len, :]
        x = self.dropout(x, training=training)
        outputs['encoder_layer_pos_encoding'] = x.numpy()

        for i in range(self.num_layers):
            x, enc_out = self.enc_layers[i](x, training, mask, i)
            outputs.update(enc_out)

        return x, outputs  # (batch_size, input_seq_len, d_model)

class Decoder(tf.keras.layers.Layer):
    def __init__(self, num_layers, d_model, num_heads, dff, target_vocab_size,
                 maximum_position_encoding, rate=0.1):
        super(Decoder, self).__init__()

        self.d_model = d_model
        self.num_layers = num_layers

        self.embedding = tf.keras.layers.Embedding(target_vocab_size, d_model)
        self.pos_encoding = positional_encoding(maximum_position_encoding, d_model)

        self.dec_layers = [DecoderLayer(d_model, num_heads, dff, rate)
                           for _ in range(num_layers)]
        self.dropout = tf.keras.layers.Dropout(rate)

    def call(self, x, enc_output, training,
             look_ahead_mask, padding_mask):
        outputs = {}

        seq_len = tf.shape(x)[1]
        attention_weights = {}

        x = self.embedding(x)  # (batch_size, target_seq_len, d_model)
        outputs['decoder_layer_embedding'] = x.numpy()

        x *= tf.math.sqrt(tf.cast(self.d_model, tf.float32))
        outputs['decoder_layer_mult_sqrt'] = x.numpy()

        x += self.pos_encoding[:, :seq_len, :]
        x = self.dropout(x, training=training)
        outputs['decoder_layer_pos_encoding'] = x.numpy()

        for i in range(self.num_layers):
            x, block1, block2, dec_outs = self.dec_layers[i](x, enc_output, training,
                                                   look_ahead_mask, padding_mask, i)

            attention_weights[f'decoder_layer{i+1}_block1'] = block1
            attention_weights[f'decoder_layer{i+1}_block2'] = block2
            outputs.update(dec_outs)

        # x.shape == (batch_size, target_seq_len, d_model)
        return x, attention_weights, outputs

class Transformer(tf.keras.Model):
    def __init__(self, num_layers, d_model, num_heads, dff, input_vocab_size,
                 target_vocab_size, pe_input, pe_target, rate=0.1):
        super(Transformer, self).__init__()

        self.encoder = Encoder(num_layers, d_model, num_heads, dff,
                               input_vocab_size, pe_input, rate)

        self.decoder = Decoder(num_layers, d_model, num_heads, dff,
                               target_vocab_size, pe_target, rate)

        self.final_layer = tf.keras.layers.Dense(target_vocab_size)

    def __call__(self, inputs, training):
        outputs = {}

        inp, tar, enc_padding_mask, look_ahead_mask, dec_padding_mask = inputs
        enc_output, enc_outs = self.encoder(inp, training, enc_padding_mask)  # (batch_size, inp_seq_len, d_model)
        outputs.update(enc_outs)

        # dec_output.shape == (batch_size, tar_seq_len, d_model)
        dec_output, attention_weights, dec_outs = self.decoder(
            tar, enc_output, training, look_ahead_mask, dec_padding_mask)
        outputs.update(dec_outs)

        final_output = self.final_layer(dec_output)  # (batch_size, tar_seq_len, target_vocab_size)
        outputs['final_dense_layer'] = final_output.numpy()

        return final_output, attention_weights, outputs

class CustomSchedule(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, d_model, warmup_steps=4000):
        super(CustomSchedule, self).__init__()

        self.d_model = d_model
        self.d_model = tf.cast(self.d_model, tf.float32)

        self.warmup_steps = warmup_steps

    def __call__(self, step):
        arg1 = tf.math.rsqrt(step)
        arg2 = step * (self.warmup_steps ** -1.5)

        return tf.math.rsqrt(self.d_model) * tf.math.minimum(arg1, arg2)

def loss_function(real, pred):
    mask = tf.math.logical_not(tf.math.equal(real, 0))
    loss_ = loss_object(real, pred)

    mask = tf.cast(mask, dtype=loss_.dtype)
    loss_ *= mask

    return tf.reduce_sum(loss_)/tf.reduce_sum(mask)


def accuracy_function(real, pred):
    accuracies = tf.equal(real, tf.argmax(pred, axis=2))

    mask = tf.math.logical_not(tf.math.equal(real, 0))
    accuracies = tf.math.logical_and(mask, accuracies)

    accuracies = tf.cast(accuracies, dtype=tf.float32)
    mask = tf.cast(mask, dtype=tf.float32)
    return tf.reduce_sum(accuracies)/tf.reduce_sum(mask)

def create_masks(inp, tar):
    # Encoder padding mask
    enc_padding_mask = create_padding_mask(inp)

    # Used in the 2nd attention block in the decoder.
    # This padding mask is used to mask the encoder outputs.
    dec_padding_mask = create_padding_mask(inp)

    # Used in the 1st attention block in the decoder.
    # It is used to pad and mask future tokens in the input received by
    # the decoder.
    look_ahead_mask = create_look_ahead_mask(tf.shape(tar)[1])
    dec_target_padding_mask = create_padding_mask(tar)
    combined_mask = tf.maximum(dec_target_padding_mask, look_ahead_mask)

    return enc_padding_mask, combined_mask, dec_padding_mask

data = pd.read_csv('data/translation.tsv', sep = '\t', header=None)
Eng = data[0]
Jp = data[1]
English , token_English , sent_English = preprocess_input(Eng)
Japanese , token_Japanese , sent_Japanese = preprocess_input(Jp)

print("English vocabulary size:", len(token_English.word_index))
print("Japanese vocabulary size:", len(token_Japanese.word_index))
print("English Longest sentence size:", len(English[0]))
print("Japanese Longest sentence size:", len(Japanese[0]))

num_layers = 6
d_model = 512
dff = 1024
num_heads = 8

input_vocab_size = len(token_English.word_index) + 2
target_vocab_size = len(token_Japanese.word_index) + 2
dropout_rate = 0.1
learning_rate = CustomSchedule(d_model)
optimizer = tf.keras.optimizers.Adam(learning_rate, beta_1=0.9, beta_2=0.98,
                                     epsilon=1e-9)
loss_object = tf.keras.losses.SparseCategoricalCrossentropy(
    from_logits=True, reduction='none')

train_loss = tf.keras.metrics.Mean(name='train_loss')
train_accuracy = tf.keras.metrics.Mean(name='train_accuracy')

transformer = Transformer(num_layers, d_model, num_heads, dff,
                          input_vocab_size, target_vocab_size,
                          pe_input=input_vocab_size,
                          pe_target=target_vocab_size,
                          rate=dropout_rate)

checkpoint_path = "./checkpoints"

ckpt = tf.train.Checkpoint(transformer=transformer,
                           optimizer=optimizer)

ckpt_manager = tf.train.CheckpointManager(ckpt, checkpoint_path, max_to_keep=5)

# if a checkpoint exists, restore the latest checkpoint.
if ckpt_manager.latest_checkpoint:
    ckpt.restore(ckpt_manager.latest_checkpoint).expect_partial()
    print('Latest checkpoint restored!!')

EPOCHS = 0
batch_size = 512

# The @tf.function trace-compiles train_step into a TF graph for faster
# execution. The function specializes to the precise shape of the argument
# tensors. To avoid re-tracing due to the variable sequence lengths or variable
# batch sizes (the last batch is smaller), use input_signature to specify
# more generic shapes.

train_step_signature = [
    tf.TensorSpec(shape=(batch_size, len(English[0])), dtype=tf.int64),
    tf.TensorSpec(shape=(batch_size, len(Japanese[0])), dtype=tf.int64),
]
@tf.function(input_signature=train_step_signature)
def train_step(inp, tar):
    tar_inp = tar[:, :-1]
    tar_real = tar[:, 1:]

    enc_padding_mask, combined_mask, dec_padding_mask = (inp, tar_inp)
    #tf.print(enc_padding_mask.shape, combined_mask.shape, dec_padding_mask.shape)
    with tf.GradientTape() as tape:
          #tf.print(inp.shape , tar_inp.shape, tar_real.shape )
          predictions, _ , _ = transformer([inp, tar_inp,
                                       enc_padding_mask,
                                       combined_mask,
                                       dec_padding_mask],
                                       True)

          #tf.print(predictions.shape)
          loss = loss_function(tar_real, predictions)
          #tf.print(loss)

    gradients = tape.gradient(loss, transformer.trainable_variables)
    optimizer.apply_gradients(zip(gradients, transformer.trainable_variables))

    train_loss(loss)
    train_accuracy(accuracy_function(tar_real, predictions))

for epoch in range(EPOCHS):
    start = time.time()

    train_loss.reset_states()
    train_accuracy.reset_states()

    English, Japanese = shuffle(English, Japanese)

    start_pt = 0
    # inp -> english, tar -> japanese
    for i in range(int(len(English)/batch_size)):
        inp = tf.convert_to_tensor(np.array(English[start_pt:start_pt+batch_size]),dtype=tf.int64)
        tar = tf.convert_to_tensor(np.array(Japanese[start_pt:start_pt+batch_size]),dtype=tf.int64)
        start_pt = start_pt + batch_size
        train_step(inp, tar)

        if i % 100 == 0:
            print ('Epoch {} Batch {} Loss {:.4f} Accuracy {:.4f}'.format(
                epoch + 1, i, train_loss.result(), train_accuracy.result()))

    if (epoch + 1) % 5 == 0:
        ckpt_save_path = ckpt_manager.save()
        print ('Saving checkpoint for epoch {} at {}'.format(epoch+1,
                                                             ckpt_save_path))

    print ('Epoch {} Loss {:.4f} Accuracy {:.4f}'.format(epoch + 1,
                                                  train_loss.result(),
                                                  train_accuracy.result()))

    print ('Total time taken for that epoch: {} secs\n'.format(time.time() - start))

def evaluate(sentence):
    sentence[0] = '<SOS> ' + sentence[0] + ' <EOS>'
    sentence = pad(token_English.texts_to_sequences(sentence) , length = len(English[0]))
    sentence = tf.convert_to_tensor(np.array(sentence),dtype=tf.int64)

    decoder_input = tf.convert_to_tensor(np.array(token_Japanese.texts_to_sequences(['SOS'])),dtype=tf.int64)

    outputs = None
    for i in range(len(English[0])):
        enc_padding_mask, combined_mask, dec_padding_mask = create_masks(
            sentence, decoder_input)
        #tf.print(enc_padding_mask.shape, combined_mask.shape, dec_padding_mask.shape)
        # predictions.shape == (batch_size, seq_len, vocab_size)
        predictions, attention_weights, out = transformer([sentence,
                                                     decoder_input,
                                                     enc_padding_mask,
                                                     combined_mask,
                                                     dec_padding_mask],
                                                     False)

        # select the last word from the seq_len dimension
        predictions = predictions[: ,-1:, :]  # (batch_size, 1, vocab_size)

        predicted_id = tf.cast(tf.argmax(predictions, axis=-1), tf.int64)

        #tf.print(predicted_id,decoder_input)
        # return the result if the predicted_id is equal to the end token
        if predicted_id == token_Japanese.texts_to_sequences(['EOS']):
            out['input_sentence'] = sentence.numpy()
            return tf.squeeze(decoder_input, axis=0), attention_weights , sentence, out

        # concatentate the predicted_id to the output which is given to the decoder
        # as its input.
        decoder_input = tf.concat([decoder_input, predicted_id], axis=1)
        outputs = out

    outputs['input_sentence'] = sentence.numpy()
    return tf.squeeze(decoder_input, axis=0), attention_weights, sentence, outputs

def plot_attention_weights(attention, sentence_vec, result_vec, sentence , result, layer):
    fprop = fm.FontProperties(fname='NotoSansJP-Regular.otf')
    fig = plt.figure(figsize=(16, 8))
    attention = tf.squeeze(attention[layer], axis=0)
    sent = sentence.split(" ")
    res = result.split(" ")
    slt = []

    for s in sent:
        slt.append(s)
    rlt = []

    for s in res:
        rlt.append(s)
    res = result.split(" ")

    for head in range(attention.shape[0]):
        ax = fig.add_subplot(2, 4, head+1)

        # plot the attention weights
        ax.matshow(attention[head][:-1, :], cmap='viridis')

        fontdict = {'fontsize': 10}

        ax.set_xticks(range(len(slt)))
        ax.set_yticks(range(len(rlt)))

        ax.set_ylim(len(result_vec)-1.5, -0.5)

        ax.set_xticklabels(
            slt,
            fontdict=fontdict, rotation=90, fontproperties=fprop)

        ax.set_yticklabels(rlt,
                           fontdict=fontdict, fontproperties=fprop)

        ax.set_xlabel('Head {}'.format(head+1))

    plt.tight_layout()
    plt.show()

def toJapanese(word):
    sent = ""
    for i in word:
        if i == 0: break
        if i != 2 and i != 1:
            sent = sent + [key for key, value in token_Japanese.word_index.items() if value == i][0]+" "
    return sent

def toEnglish(word):
    sent = ""
    for i in word:
        if i == 0: break
        elif i != 2 and i != 1:
            sent = sent + [key for key, value in token_English.word_index.items() if value == i][0]+" "
    return sent

def result(samples, plot=False):
    for i in range(samples):
        value = randint(0, Eng.shape[0] - 1)
        sent = [Eng[value]]
        real = [Jp[value]]
        print('En          :  ' + sent[0])
        print('Jp Actual :    ' + real[0])
        decoded, attn_wt, sentence, _ = evaluate(sent)
        print('Jp Predicted : ' + toJapanese(decoded))
        print()
        if plot:
            plot_attention_weights(attn_wt,sentence,decoded,sent[0],
                                   toJapanese(decoded),'decoder_layer6_block2')

def translate(s, plot=False, stdout=True):
    if stdout: print('En          :  ' + s)
    decoded, attn_wt, sentence, layers_out = evaluate([s])
    if stdout: print('Jp Predicted : ' + toJapanese(decoded))
    if plot:
        plot_attention_weights(attn_wt,sentence,decoded, '<SOS> ' + s + ' <EOS>',
                               toJapanese(decoded),'decoder_layer6_block2')
    return layers_out

#result(5, True)
layers_out = translate('my name is sarah and I live in london')
layers_keys = list(layers_out)

weights = transformer.get_weights()
weights_name = [i.name for i in transformer.trainable_variables]

# Post training quantization

import random
import pickle
from scipy.stats import entropy
from os.path import exists
from tqdm import tqdm
import re

# Gather 1000 samples for calibration
sampleNum = 1000
samplesPath = "./save_model/calibration/"
samples = []

pat = re.compile('.*(_q$|_k$|_v$|encoding|dense|ffn).*')
compare_keys = [x for x in layers_keys if not pat.match(x) == None]

file_exists = exists(samplesPath + "sample" + str(sampleNum - 1) + ".npy")
if not (file_exists):
    print("Caching model outputs for quantization calibration...")
    sampInd = random.sample(range(0, len(data[0]) - 1), sampleNum)
    for si in tqdm(range(sampleNum)):
        layers_out = translate(data[0][sampInd[si]], False, False)
        samples.append(layers_out)
        f = open(samplesPath + "sample" + str(si) + ".npy", "wb")
        # write the python object (dict) to pickle file
        pickle.dump(layers_out, f)
        f.close()
else:
    print("Loading model outputs for quantization calibration...")
    for si in range(sampleNum):
        f = open(samplesPath + "sample" + str(si) + ".npy", "rb")
        outputs = pickle.load(f)
        samples.append(outputs)
        f.close()

def quantize(x, s, z):
    return np.clip(np.round(s * x + z), -128, 127)

def dequantize(xq, s, z):
    return (xq - z) * (1.0 / s)

def QuantizationGA(weights, max_iters, children, sampleCount, mutation):
    print("Starting quantization calibration...")
    bestWeights = []
    bestParams = []
    bestScores = []
    
    # initalization
    curParams = []
    for w in weights:
        cw = w.flatten()
        beta = min(cw)
        alpha = max(cw)
        scale = 255.0 / (alpha - beta)
        zp = -round(beta * scale) - 128
        curParams.append([alpha, beta, scale, zp])
    
    # save 2 of the best, initally it's the same
    for i in range(2):
        bestWeights.append(weights)
        bestParams.append(curParams)
        bestScores.append(np.inf)
    
    try:
        # generations
        for itn in range(max_iters):
            # children
            childWeights = []
            childParams = []
            childScores = []
            
            for child in tqdm(range(children)):
                # mutations
                p1 = bestParams[0]
                p2 = bestParams[1]
                
                curParams = []
                for i in range(len(weights)):
                    # swap
                    alpha = p1[0] if random.random() < mutation else p2[0]
                    beta = p1[1] if random.random() < mutation else p2[1]
                    
                    dist = abs(alpha - beta)
                    
                    # step
                    alpha = alpha + (random.random() - 0.5) * dist * 0.15
                    beta = beta + (random.random() - 0.5) * dist * 0.15
                    
                    # random hops
                    alpha = alpha if random.random() < mutation else (random.random() - 0.5) * dist
                    beta = beta if random.random() < mutation else (random.random() - 0.5) * dist
                    
                    scale = 255.0 / (alpha - beta)
                    zp = -round(beta * scale) - 128
                        
                    curParams.append([alpha, beta, scale, zp])
                    
                childParams.append(curParams)
                
                newWeights = []
                for i in range(len(weights)):
                    newWeights.append(quantize(weights[i], curParams[i][2], curParams[i][3]))
                
                childWeights.append(newWeights)
                
                for i in range(len(weights)):
                    newWeights[i] = dequantize(newWeights[i], curParams[i][2], curParams[i][3])
                
                # cumulative entropy score
                score = 0
                
                # entroy calculation
                transformer.set_weights(newWeights)
                
                # randomly pick 100
                for ind in random.sample(range(sampleNum), sampleCount):
                    str_in = toEnglish(samples[ind]['input_sentence'][0]).strip()
                    layers_out = translate(str_in, False, False)
                    # compare layers
                    for name in compare_keys:
                        l1 = samples[ind][name]
                        l2 = layers_out[name]
    
                        # reshape to the same shape
                        if l1.shape[1] > l2.shape[1]:
                            d = l1.shape[1] - l2.shape[1]
                            npad = ((0, 0), (0, d), (0, 0))
                            l2 = np.pad(l2, pad_width=npad, mode='constant', constant_values = 10000.0)
                        elif l2.shape[1] > l1.shape[1]:
                            d = l2.shape[1] - l1.shape[1]
                            npad = ((0, 0), (0, d), (0, 0))
                            l1 = np.pad(l1, pad_width=npad, mode='constant', constant_values = 10000.0)
                        
                        # non zero positive values
                        l1 = l1.flatten()
                        l2 = l2.flatten()
                        
                        lmin = min(min(l1), min(l2))
                        
                        if lmin <= 0.0:
                            lmin = -lmin + 0.0001
                            l1 = l1 + lmin
                            l2 = l2 + lmin
                        
                        layer_score = entropy(l1, qk = l2)
                        if name == 'final_dense_layer':
                            layer_score = layer_score * 20
                        score = score + layer_score
                        
                childScores.append(score)
                
            # add best scoring child
            bestIndex = childScores.index(min(childScores))
            bestWeights.append(childWeights[bestIndex])
            bestParams.append(childParams[bestIndex])
            bestScores.append(childScores[bestIndex])
            
            # sort based on score
            sorted_lists = sorted(zip(bestWeights, bestParams, bestScores), key=lambda x: x[2])
            sWeights, sParams, sScores = [[x[i] for x in sorted_lists] for i in range(3)]
    
            # keep a copy of the previous generation
            bestWeights = sWeights[0:2]
            bestParams = sParams[0:2]
            bestScores = sScores[0:2]
            
            print("\nGeneration: %i - scores: %f, %f" % (itn, bestScores[0], bestScores[1]))
            print("Best Parameters:")
            print(bestParams)
            
        except KeyboardInterrupt:
            pass
        
    return bestWeights, bestParams, bestScores

bestWeights, bestParams, bestScores = QuantizationGA(weights, 2, 5, 5, 0.9)

# Write weights

if 0:

    print("Exporting data.")

    def write_weights(array, dest, mode='ab'):
        with open(dest, mode) as f:
            if (len(array.shape) == 4):
                for i in range(0, len(array)):
                    for j in range(0, len(array[0])):
                        for k in range(0, len(array[0][0])):
                            for l in range(0, len(array[0][0][0])):
                                f.write(struct.pack('f', array[i][j][k][l]))
            elif (len(array.shape) == 3):
                for i in range(0, len(array)):
                    for j in range(0, len(array[0])):
                        for k in range(0, len(array[0][0])):
                            f.write(struct.pack('f', array[i][j][k]))
            elif (len(array.shape) == 2):
                for i in range(0, len(array)):
                    for j in range(0, len(array[0])):
                            f.write(struct.pack('f', array[i][j]))
            elif (len(array.shape) == 1):
                for i in range(0, len(array)):
                    f.write(struct.pack('f', array[i]))
            f.close()
    
    dest = './save_model/eng2jp_weights.bytes'
    
    try:
        os.remove(dest)
    except OSError:
        pass
    for i in range(0, len(weights)):
        write_weights(weights[i], dest)
    
    with open("./data/eng_seq2text.tsv", "w", encoding="utf-8") as f:
        for k, v in token_English.word_index.items():
            if v == 1 or v == 2: continue #sos eos
            f.write("%s\t%s\n" % (k, v))
    
    eng_dict = collections.OrderedDict(sorted(token_English.word_index.items()))
    
    with open("./data/eng_text2seq.tsv", "w", encoding="utf-8") as f:
        for k, v in eng_dict.items():
            f.write("%s\t%s\n" % (k, v))
        
    with open("./data/jp_seq2text.tsv", "w", encoding="utf-8") as f:
        for k, v in token_Japanese.word_index.items():
            if v == 1 or v == 2: continue #sos eos
            f.write("%s\t%s\n" % (k, v))
