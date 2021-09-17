import re
import pandas as pd
import os
import xml.etree.ElementTree as ET

def removePuntuationJP(s):
    punc = "-\[\]･'゜⨯゛♫~-♪\"!?➡・！？｡。＂＃＄％＆＇()（）＊＋，－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､、〃》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰〾〿–—‘’‛“”„‟…‧﹏. "
    s = re.sub("[%s]+" %punc, "", s)
    s = s.replace('ﾞ', '')
    return s.strip()

def removePuntuationEN(s):
    s = s.replace('-', ' ')
    s = re.sub("[^\w\d'\s]+", "", s)
    s = re.sub(r"(\d+)(\w*)", r"\1 \2", s)
    return s.strip()

def isEnglish(s):
    try:
        s.encode(encoding='utf-8').decode('ascii')
    except UnicodeDecodeError:
        return False
    else:
        return True

# Tatoeba dataset

sentences = {}
sentence_lang = {}
with open("./data/sentences.csv", encoding="utf-8") as f:
    for line in f:
        i, lang, sentence = line.strip("\n").split("\t")
        sentence_lang[i] = lang
        if lang == "eng" or lang == "jpn":
            sentences[i] = sentence

translations = []
with open("./data/links.csv") as f:
    for line in f:
        i, j = line.strip("\n").split("\t")
        if i in sentences and j in sentences and sentence_lang[i] == "eng" and sentence_lang[j] == "jpn":
            translations.append((sentences[i], sentences[j]))

# JEC Simple sentences

xlsx = pd.ExcelFile("data/JEC_basic_sentence_v1-3/JEC_basic_sentence_v1-3.xlsx")
sheetX = xlsx.parse(0)
for i in range(len(sheetX)):
    translations.append((sheetX['eng'][i], sheetX['jpn'][i]))

# TED talks

en_files = ['ted_en-20140120.xml', 'ted_en-20150530.xml', 'ted_en-20160408.xml']
jp_files = ['ted_ja-20140120.xml', 'ted_ja-20150530.xml', 'ted_ja-20160408.xml']

for fileNo in range(len(en_files)):
    root_en = ET.parse('data/ted/' + en_files[fileNo]).getroot()
    root_jp = ET.parse('data/ted/' + jp_files[fileNo]).getroot()
    
    en_ids = {}
    for child in root_en:
        en_ids[child[0][6].text] = child.get('id')
        
    jp_ids = {}
    for child in root_jp:
        jp_ids[child[0][6].text] = child.get('id')
        
    en_set = set(en_ids.keys())
    jp_set = set(jp_ids.keys())
    
    talks_both = en_set.intersection(jp_set)
    
    en_id2index = {}
    for i in range(len(root_en)):
        en_id2index[root_en[i].get('id')] = i
    
    jp_id2index = {}
    for i in range(len(root_jp)):
        jp_id2index[root_jp[i].get('id')] = i

    for talk in talks_both:
        en_id = int(en_id2index.get(en_ids.get(talk)))
        jp_id = int(jp_id2index.get(jp_ids.get(talk)))
        en_transcript = root_en[en_id][0][7]
        jp_transcript = root_jp[jp_id][0][7]
        for en, jp in zip(en_transcript, jp_transcript):
            translations.append((en.text, jp.text))

eng_chars = set()
eng_vocabs = set()
jpn_vocabs = set()
with open("./data/translation.tsv", "w", encoding="utf-8") as f:
    for eng, jpn in translations:
        if (eng is None) or (jpn is None): continue
        eng = eng.lower()
        eng = removePuntuationEN(eng)
        eng_set = set(eng)
        skip = False
        for letter in eng_set:
            if isEnglish(letter) == False:
                skip = True
        if not skip: eng_chars |= eng_set
        eng_set = set(eng.split(' '))
        for word in eng_set:
            if len(word) == 0: continue
            if len(word) > 20: skip = True
            if word[0] == '\'': skip = True
        jpn = removePuntuationJP(jpn).replace(" ", "")
        jpn_set = set(jpn)
        if (len(eng.split(' ')) > 20) or (len(jpn) > 20): skip = True
        if (len(eng) == 0) or (len(jpn) == 0): skip = True
        if (isEnglish(jpn)): skip = True
        if eng.isnumeric(): skip = True
        if jpn.isnumeric(): skip = True
        if skip: continue
        eng_vocabs |= eng_set
        jpn_vocabs |= jpn_set
        f.write("%s\t%s\n" % (eng, " ".join(jpn)))

# ASPEC-JE
translations = []
PATH = 'data\\ASPEC\\ASPEC-JE\\train'
for i in [os.path.join(PATH, f) for f in os.listdir(PATH)]:
    with open(i, encoding="utf-8") as f:
        for line in f:
            _, _, _, jpn, eng = line.strip("\n").split(" ||| ")
            translations.append((eng.strip(), jpn.strip()))

# Wikipedia Kyoto

for root, dirs, files in os.walk('data/wiki_corpus_2.01'):
    for file in files:
        path = os.path.join(root, file)
        file = open(path, mode='r', encoding='utf-8')
        contents = file.read().replace('&apos;', '\'')
        jp_regex = '(?<=<j>).+(?=<\/j>)'
        jp_match = re.findall(jp_regex, contents)
        en_regex = '(?<=<e type=\"check\" ver=\"1\">).+(?=<\/e>)'
        en_match = re.findall(en_regex, contents)
        if not (len(en_match) == len(jp_match)):
            continue
        for i in range(len(en_match)):
            translations.append((en_match[i], jp_match[i]))

with open("./data/translation.tsv", "a", encoding="utf-8") as f:
    for eng, jpn in translations:
        if (eng is None) or (jpn is None): continue
        eng = eng.lower()
        eng = removePuntuationEN(eng)
        eng_set = set(eng)
        skip = False
        for letter in eng_set:
            if isEnglish(letter) == False:
                skip = True
        if not skip: eng_chars |= eng_set
        eng_set = set(eng.split(' '))
        if not eng_set.issubset(eng_vocabs): continue
        for word in eng_set:
            if len(word) == 0: continue
            if len(word) > 20: skip = True
            if word[0] == '\'': skip = True
        jpn = removePuntuationJP(jpn).replace(" ", "")
        jpn_set = set(jpn)
        if not jpn_set.issubset(jpn_vocabs): skip = True
        if (len(eng.split(' ')) > 20) or (len(jpn) > 20): skip = True
        if (len(eng) == 0) or (len(jpn) == 0): skip = True
        if (isEnglish(jpn)): skip = True
        if eng.isnumeric(): skip = True
        if jpn.isnumeric(): skip = True
        if skip: continue
        eng_vocabs |= eng_set
        jpn_vocabs |= jpn_set
        f.write("%s\t%s\n" % (eng, " ".join(jpn)))
        
with open("./data/vocab.txt", "w", encoding="utf-8") as f:
    for line in sorted(eng_vocabs, key=len):
        f.write("%s\n" % (line))