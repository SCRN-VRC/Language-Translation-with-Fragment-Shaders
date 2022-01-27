
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>
#include <map>
#include <vector>
#include <thread>
#include <sstream>
#include <algorithm>
#include <Windows.h> 
#include <codecvt>

#define uint unsigned int

class jp2eng
{
private:

    // Links baked weight into each encoder layer
    struct encoder_weights {
        int number;
        float** mhaQ_w;
        float* mhaQ_b;
        float** mhaK_w;
        float* mhaK_b;
        float** mhaV_w;
        float* mhaV_b;
        float** mhaO_w;
        float* mhaO_b;
        float* norm1_gamma;
        float* norm1_beta;
        float** ffn1_w;
        float* ffn1_b;
        float** ffn2_w;
        float* ffn2_b;
        float* norm2_gamma;
        float* norm2_beta;
    };

    // Encoder layer output structure
    struct encoder_block {
        int number;
        float** lmhaQ;      // multi head attention query
        float** lmhaK;      // multi head attention key
        float** lmhaV;      // multi head attention value
        float*** lsatQK;    // scaled attention step q * k
        float*** lsoft;     // scaled attention step softmax
        float*** lsatSV;    // scaled attention step soft * v
        float** lmhaO;      // multi head attention, dense_out
        float* lmean1;      // normalize mean
        float* lvar1;       // normalize variance
        float** lnorm1;     // normalize layer 1
        float** lffn1;      // point wise feed forward 1
        float** lffn2;      // point wise feed forward 2
        float* lmean2;      // normalize mean
        float* lvar2;       // normalize variance
        float** lnorm2;     // normalize layer 2
        encoder_weights weights;
    };

    // Links baked weight into each decode layer
    struct decoder_weights {
        int number;
        float** mha1Q_w;
        float* mha1Q_b;
        float** mha1K_w;
        float* mha1K_b;
        float** mha1V_w;
        float* mha1V_b;
        float** mha1O_w;
        float* mha1O_b;
        float* norm1_gamma;
        float* norm1_beta;
        float** mha2Q_w;
        float* mha2Q_b;
        float** mha2K_w;
        float* mha2K_b;
        float** mha2V_w;
        float* mha2V_b;
        float** mha2O_w;
        float* mha2O_b;
        float* norm2_gamma;
        float* norm2_beta;
        float** ffn1_w;
        float* ffn1_b;
        float** ffn2_w;
        float* ffn2_b;
        float* norm3_gamma;
        float* norm3_beta;
    };

    // Decoder layer output structure
    struct decoder_block {
        int number;
        float** lmha1Q;      // multi head attention query
        float** lmha1K;      // multi head attention key
        float** lmha1V;      // multi head attention value
        float*** lsat1QK;    // scaled attention step q * k
        float*** lsoft1;     // scaled attention step softmax
        float*** lsat1SV;    // scaled attention step soft * v
        float** lmha1O;      // multi head attention, dense_out
        float* lmean1;       // normalize mean
        float* lvar1;        // normalize variance
        float** lnorm1;      // normalize layer 1
        float** lmha2Q;      // multi head attention query 2
        float** lmha2K;      // multi head attention key 2
        float** lmha2V;      // multi head attention value 2
        float*** lsat2QK;    // scaled attention step q * k 2
        float*** lsoft2;     // scaled attention step softmax 2
        float*** lsat2SV;    // scaled attention step soft * v 2
        float** lmha2O;      // multi head attention, dense_out 2
        float* lmean2;       // normalize mean 2
        float* lvar2;        // normalize variance 2
        float** lnorm2;      // normalize layer 2
        float** lffn1;       // point wise feed forward 1
        float** lffn2;       // point wise feed forward 2
        float* lmean3;       // normalize mean 3
        float* lvar3;        // normalize variance 3
        float** lnorm3;      // normalize layer 3
        decoder_weights weights;
    };

    float epsilon = 1e-6f;

    std::map<std::wstring, uint> jpMap;
    std::vector<std::string> engMap;

    // 6 layers of the encoder
    encoder_block encoder_array[6];
    decoder_block decoder_array[6];

    // weights
    float** const0, ** const1, ** const3, ** const5, ** const7, ** const9, ** const11,
        ** const17, ** const19, ** const21, ** const23, ** const25, ** const27, ** const33,
        ** const35, ** const37, ** const39, ** const41, ** const43, ** const49, ** const51,
        ** const53, ** const55, ** const57, ** const59, ** const65, ** const67, ** const69,
        ** const71, ** const73, ** const75, ** const81, ** const83, ** const85, ** const87,
        ** const89, ** const91, ** const97, ** const98, ** const100, ** const102, ** const104,
        ** const106, ** const108, ** const110, ** const112, ** const114, ** const116,
        ** const124, ** const126, ** const128, ** const130, ** const132, ** const134,
        ** const136, ** const138, ** const140, ** const142, ** const150, ** const152,
        ** const154, ** const156, ** const158, ** const160, ** const162, ** const164,
        ** const166, ** const168, ** const176, ** const178, ** const180, ** const182,
        ** const184, ** const186, ** const188, ** const190, ** const192, ** const194,
        ** const202, ** const204, ** const206, ** const208, ** const210, ** const212,
        ** const214, ** const216, ** const218, ** const220, ** const228, ** const230,
        ** const232, ** const234, ** const236, ** const238, ** const240, ** const242,
        ** const244, ** const246, ** const254;

    // norm + bias
    float* const2, * const4, * const6, * const8, * const10, * const12, * const13, * const14,
        * const15, * const16, * const18, * const20, * const22, * const24, * const26, * const28,
        * const29, * const30, * const31, * const32, * const34, * const36, * const38, * const40,
        * const42, * const44, * const45, * const46, * const47, * const48, * const50, * const52,
        * const54, * const56, * const58, * const60, * const61, * const62, * const63, * const64,
        * const66, * const68, * const70, * const72, * const74, * const76, * const77, * const78,
        * const79, * const80, * const82, * const84, * const86, * const88, * const90, * const92,
        * const93, * const94, * const95, * const96, * const99, * const101, * const103,
        * const105, * const107, * const109, * const111, * const113, * const115, * const117,
        * const118, * const119, * const120, * const121, * const122, * const123, * const125,
        * const127, * const129, * const131, * const133, * const135, * const137, * const139,
        * const141, * const143, * const144, * const145, * const146, * const147, * const148,
        * const149, * const151, * const153, * const155, * const157, * const159, * const161,
        * const163, * const165, * const167, * const169, * const170, * const171, * const172,
        * const173, * const174, * const175, * const177, * const179, * const181, * const183,
        * const185, * const187, * const189, * const191, * const193, * const195, * const196,
        * const197, * const198, * const199, * const200, * const201, * const203, * const205,
        * const207, * const209, * const211, * const213, * const215, * const217, * const219,
        * const221, * const222, * const223, * const224, * const225, * const226, * const227,
        * const229, * const231, * const233, * const235, * const237, * const239, * const241,
        * const243, * const245, * const247, * const248, * const249, * const250, * const251,
        * const252, * const253, * const255;

    // masks
    float** encoderMask, ** decoderTargetMask;

    // layers
    float** encoder_in, ** decoder_in, ** final_out;

    float**** getArray(std::ifstream* fin, int mi, int mj, int mk, int ml)
    {
        float**** buff = (float****)createArray(mi, mj, mk, ml, sizeof(float));
        for (int i = 0; i < mi; i++) {
            for (int j = 0; j < mj; j++) {
                for (int k = 0; k < mk; k++) {
                    fin->read(reinterpret_cast<char*>(buff[i][j][k]), sizeof(float) * ml);
                }
            }
        }
        return buff;
    }

    float*** getArray(std::ifstream* fin, int mi, int mj, int mk)
    {
        float*** buff = (float***)createArray(mi, mj, mk, sizeof(float));
        for (int i = 0; i < mi; i++) {
            for (int j = 0; j < mj; j++) {
                fin->read(reinterpret_cast<char*>(buff[i][j]), sizeof(float) * mk);
            }
        }
        return buff;
    }

    float** getArray(std::ifstream* fin, int mi, int mj)
    {
        float** buff = (float**)createArray(mi, mj, sizeof(float));
        for (int i = 0; i < mi; i++) {
            fin->read(reinterpret_cast<char*>(buff[i]), sizeof(float) * mj);
        }
        return buff;
    }

    float* getArray(std::ifstream* fin, int mi)
    {
        float* buff = (float*)malloc(mi * sizeof(float));
        fin->read(reinterpret_cast<char*>(buff), sizeof(float) * mi);
        return buff;
    }

public:
    // Annoying mallocs
    static float** createArray(int i, int j, size_t size)
    {
        float** r = new float* [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float[j * size];
        }
        return r;
    }

    static float*** createArray(int i, int j, int k, size_t size)
    {
        float*** r = new float** [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float* [j * sizeof(float*)];
            for (int y = 0; y < j; y++) {
                r[x][y] = new float[k * size];
            }
        }
        return r;
    }

    static float**** createArray(int i, int j, int k, int l, size_t size)
    {
        float**** r = new float*** [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float** [j * sizeof(float*)];
            for (int y = 0; y < j; y++) {
                r[x][y] = new float* [k * sizeof(float*)];
                for (int z = 0; z < k; z++) {
                    r[x][y][z] = new float[l * size];
                }
            }
        }
        return r;
    }

    // Annoying malloc frees
    static void freeArray(int i, float* a)
    {
        delete[] a;
    }

    static void freeArray(int i, int j, float** a)
    {
        for (int x = 0; x < i; x++) {
            delete[] a[x];
        }
        delete[] a;
    }

    static void freeArray(int i, int j, int k, float*** a)
    {
        for (int x = 0; x < i; x++) {
            for (int y = 0; y < j; y++) {
                delete[] a[x][y];
            }
            delete[] a[x];
        }
        delete[] a;
    }

    static void freeArray(int i, int j, int k, int l, float**** a)
    {
        for (int x = 0; x < i; x++) {
            for (int y = 0; y < j; y++) {
                for (int z = 0; z < k; z++) {
                    delete[] a[x][y][z];
                }
                delete[] a[x][y];
            }
            delete[] a[x];
        }
        delete[] a;
    }

    jp2eng(std::string pathWeights, std::string pathText2Seq, std::string pathSeq2Text)
    {
        std::ifstream fin(pathWeights, std::ios::binary);
        if (!fin) {
            std::cout << "error opening stream" << std::endl;
            exit(-1);
        }

        const0 = getArray(&fin, 3229, 512);
        const1 = getArray(&fin, 512, 512);
        const2 = getArray(&fin, 512);
        const3 = getArray(&fin, 512, 512);
        const4 = getArray(&fin, 512);
        const5 = getArray(&fin, 512, 512);
        const6 = getArray(&fin, 512);
        const7 = getArray(&fin, 512, 512);
        const8 = getArray(&fin, 512);
        const9 = getArray(&fin, 512, 1024);
        const10 = getArray(&fin, 1024);
        const11 = getArray(&fin, 1024, 512);
        const12 = getArray(&fin, 512);
        const13 = getArray(&fin, 512);
        const14 = getArray(&fin, 512);
        const15 = getArray(&fin, 512);
        const16 = getArray(&fin, 512);
        const17 = getArray(&fin, 512, 512);
        const18 = getArray(&fin, 512);
        const19 = getArray(&fin, 512, 512);
        const20 = getArray(&fin, 512);
        const21 = getArray(&fin, 512, 512);
        const22 = getArray(&fin, 512);
        const23 = getArray(&fin, 512, 512);
        const24 = getArray(&fin, 512);
        const25 = getArray(&fin, 512, 1024);
        const26 = getArray(&fin, 1024);
        const27 = getArray(&fin, 1024, 512);
        const28 = getArray(&fin, 512);
        const29 = getArray(&fin, 512);
        const30 = getArray(&fin, 512);
        const31 = getArray(&fin, 512);
        const32 = getArray(&fin, 512);
        const33 = getArray(&fin, 512, 512);
        const34 = getArray(&fin, 512);
        const35 = getArray(&fin, 512, 512);
        const36 = getArray(&fin, 512);
        const37 = getArray(&fin, 512, 512);
        const38 = getArray(&fin, 512);
        const39 = getArray(&fin, 512, 512);
        const40 = getArray(&fin, 512);
        const41 = getArray(&fin, 512, 1024);
        const42 = getArray(&fin, 1024);
        const43 = getArray(&fin, 1024, 512);
        const44 = getArray(&fin, 512);
        const45 = getArray(&fin, 512);
        const46 = getArray(&fin, 512);
        const47 = getArray(&fin, 512);
        const48 = getArray(&fin, 512);
        const49 = getArray(&fin, 512, 512);
        const50 = getArray(&fin, 512);
        const51 = getArray(&fin, 512, 512);
        const52 = getArray(&fin, 512);
        const53 = getArray(&fin, 512, 512);
        const54 = getArray(&fin, 512);
        const55 = getArray(&fin, 512, 512);
        const56 = getArray(&fin, 512);
        const57 = getArray(&fin, 512, 1024);
        const58 = getArray(&fin, 1024);
        const59 = getArray(&fin, 1024, 512);
        const60 = getArray(&fin, 512);
        const61 = getArray(&fin, 512);
        const62 = getArray(&fin, 512);
        const63 = getArray(&fin, 512);
        const64 = getArray(&fin, 512);
        const65 = getArray(&fin, 512, 512);
        const66 = getArray(&fin, 512);
        const67 = getArray(&fin, 512, 512);
        const68 = getArray(&fin, 512);
        const69 = getArray(&fin, 512, 512);
        const70 = getArray(&fin, 512);
        const71 = getArray(&fin, 512, 512);
        const72 = getArray(&fin, 512);
        const73 = getArray(&fin, 512, 1024);
        const74 = getArray(&fin, 1024);
        const75 = getArray(&fin, 1024, 512);
        const76 = getArray(&fin, 512);
        const77 = getArray(&fin, 512);
        const78 = getArray(&fin, 512);
        const79 = getArray(&fin, 512);
        const80 = getArray(&fin, 512);
        const81 = getArray(&fin, 512, 512);
        const82 = getArray(&fin, 512);
        const83 = getArray(&fin, 512, 512);
        const84 = getArray(&fin, 512);
        const85 = getArray(&fin, 512, 512);
        const86 = getArray(&fin, 512);
        const87 = getArray(&fin, 512, 512);
        const88 = getArray(&fin, 512);
        const89 = getArray(&fin, 512, 1024);
        const90 = getArray(&fin, 1024);
        const91 = getArray(&fin, 1024, 512);
        const92 = getArray(&fin, 512);
        const93 = getArray(&fin, 512);
        const94 = getArray(&fin, 512);
        const95 = getArray(&fin, 512);
        const96 = getArray(&fin, 512);
        const97 = getArray(&fin, 44337, 512);
        const98 = getArray(&fin, 512, 512);
        const99 = getArray(&fin, 512);
        const100 = getArray(&fin, 512, 512);
        const101 = getArray(&fin, 512);
        const102 = getArray(&fin, 512, 512);
        const103 = getArray(&fin, 512);
        const104 = getArray(&fin, 512, 512);
        const105 = getArray(&fin, 512);
        const106 = getArray(&fin, 512, 512);
        const107 = getArray(&fin, 512);
        const108 = getArray(&fin, 512, 512);
        const109 = getArray(&fin, 512);
        const110 = getArray(&fin, 512, 512);
        const111 = getArray(&fin, 512);
        const112 = getArray(&fin, 512, 512);
        const113 = getArray(&fin, 512);
        const114 = getArray(&fin, 512, 1024);
        const115 = getArray(&fin, 1024);
        const116 = getArray(&fin, 1024, 512);
        const117 = getArray(&fin, 512);
        const118 = getArray(&fin, 512);
        const119 = getArray(&fin, 512);
        const120 = getArray(&fin, 512);
        const121 = getArray(&fin, 512);
        const122 = getArray(&fin, 512);
        const123 = getArray(&fin, 512);
        const124 = getArray(&fin, 512, 512);
        const125 = getArray(&fin, 512);
        const126 = getArray(&fin, 512, 512);
        const127 = getArray(&fin, 512);
        const128 = getArray(&fin, 512, 512);
        const129 = getArray(&fin, 512);
        const130 = getArray(&fin, 512, 512);
        const131 = getArray(&fin, 512);
        const132 = getArray(&fin, 512, 512);
        const133 = getArray(&fin, 512);
        const134 = getArray(&fin, 512, 512);
        const135 = getArray(&fin, 512);
        const136 = getArray(&fin, 512, 512);
        const137 = getArray(&fin, 512);
        const138 = getArray(&fin, 512, 512);
        const139 = getArray(&fin, 512);
        const140 = getArray(&fin, 512, 1024);
        const141 = getArray(&fin, 1024);
        const142 = getArray(&fin, 1024, 512);
        const143 = getArray(&fin, 512);
        const144 = getArray(&fin, 512);
        const145 = getArray(&fin, 512);
        const146 = getArray(&fin, 512);
        const147 = getArray(&fin, 512);
        const148 = getArray(&fin, 512);
        const149 = getArray(&fin, 512);
        const150 = getArray(&fin, 512, 512);
        const151 = getArray(&fin, 512);
        const152 = getArray(&fin, 512, 512);
        const153 = getArray(&fin, 512);
        const154 = getArray(&fin, 512, 512);
        const155 = getArray(&fin, 512);
        const156 = getArray(&fin, 512, 512);
        const157 = getArray(&fin, 512);
        const158 = getArray(&fin, 512, 512);
        const159 = getArray(&fin, 512);
        const160 = getArray(&fin, 512, 512);
        const161 = getArray(&fin, 512);
        const162 = getArray(&fin, 512, 512);
        const163 = getArray(&fin, 512);
        const164 = getArray(&fin, 512, 512);
        const165 = getArray(&fin, 512);
        const166 = getArray(&fin, 512, 1024);
        const167 = getArray(&fin, 1024);
        const168 = getArray(&fin, 1024, 512);
        const169 = getArray(&fin, 512);
        const170 = getArray(&fin, 512);
        const171 = getArray(&fin, 512);
        const172 = getArray(&fin, 512);
        const173 = getArray(&fin, 512);
        const174 = getArray(&fin, 512);
        const175 = getArray(&fin, 512);
        const176 = getArray(&fin, 512, 512);
        const177 = getArray(&fin, 512);
        const178 = getArray(&fin, 512, 512);
        const179 = getArray(&fin, 512);
        const180 = getArray(&fin, 512, 512);
        const181 = getArray(&fin, 512);
        const182 = getArray(&fin, 512, 512);
        const183 = getArray(&fin, 512);
        const184 = getArray(&fin, 512, 512);
        const185 = getArray(&fin, 512);
        const186 = getArray(&fin, 512, 512);
        const187 = getArray(&fin, 512);
        const188 = getArray(&fin, 512, 512);
        const189 = getArray(&fin, 512);
        const190 = getArray(&fin, 512, 512);
        const191 = getArray(&fin, 512);
        const192 = getArray(&fin, 512, 1024);
        const193 = getArray(&fin, 1024);
        const194 = getArray(&fin, 1024, 512);
        const195 = getArray(&fin, 512);
        const196 = getArray(&fin, 512);
        const197 = getArray(&fin, 512);
        const198 = getArray(&fin, 512);
        const199 = getArray(&fin, 512);
        const200 = getArray(&fin, 512);
        const201 = getArray(&fin, 512);
        const202 = getArray(&fin, 512, 512);
        const203 = getArray(&fin, 512);
        const204 = getArray(&fin, 512, 512);
        const205 = getArray(&fin, 512);
        const206 = getArray(&fin, 512, 512);
        const207 = getArray(&fin, 512);
        const208 = getArray(&fin, 512, 512);
        const209 = getArray(&fin, 512);
        const210 = getArray(&fin, 512, 512);
        const211 = getArray(&fin, 512);
        const212 = getArray(&fin, 512, 512);
        const213 = getArray(&fin, 512);
        const214 = getArray(&fin, 512, 512);
        const215 = getArray(&fin, 512);
        const216 = getArray(&fin, 512, 512);
        const217 = getArray(&fin, 512);
        const218 = getArray(&fin, 512, 1024);
        const219 = getArray(&fin, 1024);
        const220 = getArray(&fin, 1024, 512);
        const221 = getArray(&fin, 512);
        const222 = getArray(&fin, 512);
        const223 = getArray(&fin, 512);
        const224 = getArray(&fin, 512);
        const225 = getArray(&fin, 512);
        const226 = getArray(&fin, 512);
        const227 = getArray(&fin, 512);
        const228 = getArray(&fin, 512, 512);
        const229 = getArray(&fin, 512);
        const230 = getArray(&fin, 512, 512);
        const231 = getArray(&fin, 512);
        const232 = getArray(&fin, 512, 512);
        const233 = getArray(&fin, 512);
        const234 = getArray(&fin, 512, 512);
        const235 = getArray(&fin, 512);
        const236 = getArray(&fin, 512, 512);
        const237 = getArray(&fin, 512);
        const238 = getArray(&fin, 512, 512);
        const239 = getArray(&fin, 512);
        const240 = getArray(&fin, 512, 512);
        const241 = getArray(&fin, 512);
        const242 = getArray(&fin, 512, 512);
        const243 = getArray(&fin, 512);
        const244 = getArray(&fin, 512, 1024);
        const245 = getArray(&fin, 1024);
        const246 = getArray(&fin, 1024, 512);
        const247 = getArray(&fin, 512);
        const248 = getArray(&fin, 512);
        const249 = getArray(&fin, 512);
        const250 = getArray(&fin, 512);
        const251 = getArray(&fin, 512);
        const252 = getArray(&fin, 512);
        const253 = getArray(&fin, 512);
        const254 = getArray(&fin, 512, 44337);
        const255 = getArray(&fin, 44337);

        fin.close();

        using namespace std;

        //FILE* stream;
        //wchar_t linew[100];

        //if (fopen_s(&stream, pathText2Seq.c_str(), "r") == 0)
        //{
        //    while (fgetws(linew, 100, stream) != NULL)
        //    {
        //        wstring key;
        //        uint value;
        //        wchar_t* pt;
        //        key = wcstok_s(linew, L"\t", &pt);
        //        value = stoul(wcstok_s(NULL, L"\t", &pt));
        //        jpMap.insert(pair<wstring, uint>(key, value));
        //        wprintf(L"%ls, %d\n", key, value);
        //    }
        //    fclose(stream);
        //}
        //else
        //{
        //    cout << "error opening jp file" << endl;
        //    exit(-1);
        //}

        ifstream fin3(pathSeq2Text);
        if (!fin3) {
            cout << "error opening eng file" << endl;
            exit(-1);
        }

        for (int i = 0; i < 3; i++) engMap.push_back("");

        string line;
        string token;
        while (std::getline(fin3, line))
        {
            stringstream ss(line);
            getline(ss, token, '\t');
            engMap.push_back(token);
        }

        fin3.close();

        cout << "jp vocab: " << jpMap.size() << " words loaded" << endl;
        cout << "eng vocab: " << engMap.size() << " words loaded" << endl;

        // masks
        encoderMask = (float**)createArray(22, 22, sizeof(float));
        decoderTargetMask = (float**)createArray(22, 22, sizeof(float));

        // layers
        encoder_in = (float**)createArray(22, 512, sizeof(float));
        decoder_in = (float**)createArray(22, 512, sizeof(float));
        final_out = (float**)createArray(22, 44337, sizeof(float));

        for (uint i = 0; i < 6; i++)
        {
            encoder_block* encoder = &encoder_array[i];
            encoder->number = i;
            encoder->lmhaQ = (float**)createArray(22, 512, sizeof(float));
            encoder->lmhaK = (float**)createArray(22, 512, sizeof(float));
            encoder->lmhaV = (float**)createArray(22, 512, sizeof(float));
            encoder->lsatQK = (float***)createArray(8, 22, 22, sizeof(float));
            encoder->lsoft = (float***)createArray(8, 22, 22, sizeof(float));
            encoder->lsatSV = (float***)createArray(8, 22, 64, sizeof(float));
            encoder->lmhaO = (float**)createArray(22, 512, sizeof(float));
            encoder->lmean1 = new float[22 * sizeof(float)];
            encoder->lvar1 = new float[22 * sizeof(float)];
            encoder->lnorm1 = (float**)createArray(22, 512, sizeof(float));
            encoder->lffn1 = (float**)createArray(22, 1024, sizeof(float));
            encoder->lffn2 = (float**)createArray(22, 512, sizeof(float));
            encoder->lmean2 = new float[22 * sizeof(float)];
            encoder->lvar2 = new float[22 * sizeof(float)];
            encoder->lnorm2 = (float**)createArray(22, 512, sizeof(float));
            encoder->weights.number = i;
        }

        // link baked weights to correct encoder layer

        encoder_array[0].weights.mhaQ_w = const1;
        encoder_array[0].weights.mhaQ_b = const2;
        encoder_array[0].weights.mhaK_w = const3;
        encoder_array[0].weights.mhaK_b = const4;
        encoder_array[0].weights.mhaV_w = const5;
        encoder_array[0].weights.mhaV_b = const6;
        encoder_array[0].weights.mhaO_w = const7;
        encoder_array[0].weights.mhaO_b = const8;
        encoder_array[0].weights.norm1_gamma = const13;
        encoder_array[0].weights.norm1_beta = const14;
        encoder_array[0].weights.ffn1_w = const9;
        encoder_array[0].weights.ffn1_b = const10;
        encoder_array[0].weights.ffn2_w = const11;
        encoder_array[0].weights.ffn2_b = const12;
        encoder_array[0].weights.norm2_gamma = const15;
        encoder_array[0].weights.norm2_beta = const16;

        encoder_array[1].weights.mhaQ_w = const17;
        encoder_array[1].weights.mhaQ_b = const18;
        encoder_array[1].weights.mhaK_w = const19;
        encoder_array[1].weights.mhaK_b = const20;
        encoder_array[1].weights.mhaV_w = const21;
        encoder_array[1].weights.mhaV_b = const22;
        encoder_array[1].weights.mhaO_w = const23;
        encoder_array[1].weights.mhaO_b = const24;
        encoder_array[1].weights.norm1_gamma = const29;
        encoder_array[1].weights.norm1_beta = const30;
        encoder_array[1].weights.ffn1_w = const25;
        encoder_array[1].weights.ffn1_b = const26;
        encoder_array[1].weights.ffn2_w = const27;
        encoder_array[1].weights.ffn2_b = const28;
        encoder_array[1].weights.norm2_gamma = const31;
        encoder_array[1].weights.norm2_beta = const32;

        encoder_array[2].weights.mhaQ_w = const33;
        encoder_array[2].weights.mhaQ_b = const34;
        encoder_array[2].weights.mhaK_w = const35;
        encoder_array[2].weights.mhaK_b = const36;
        encoder_array[2].weights.mhaV_w = const37;
        encoder_array[2].weights.mhaV_b = const38;
        encoder_array[2].weights.mhaO_w = const39;
        encoder_array[2].weights.mhaO_b = const40;
        encoder_array[2].weights.norm1_gamma = const45;
        encoder_array[2].weights.norm1_beta = const46;
        encoder_array[2].weights.ffn1_w = const41;
        encoder_array[2].weights.ffn1_b = const42;
        encoder_array[2].weights.ffn2_w = const43;
        encoder_array[2].weights.ffn2_b = const44;
        encoder_array[2].weights.norm2_gamma = const47;
        encoder_array[2].weights.norm2_beta = const48;

        encoder_array[3].weights.mhaQ_w = const49;
        encoder_array[3].weights.mhaQ_b = const50;
        encoder_array[3].weights.mhaK_w = const51;
        encoder_array[3].weights.mhaK_b = const52;
        encoder_array[3].weights.mhaV_w = const53;
        encoder_array[3].weights.mhaV_b = const54;
        encoder_array[3].weights.mhaO_w = const55;
        encoder_array[3].weights.mhaO_b = const56;
        encoder_array[3].weights.norm1_gamma = const61;
        encoder_array[3].weights.norm1_beta = const62;
        encoder_array[3].weights.ffn1_w = const57;
        encoder_array[3].weights.ffn1_b = const58;
        encoder_array[3].weights.ffn2_w = const59;
        encoder_array[3].weights.ffn2_b = const60;
        encoder_array[3].weights.norm2_gamma = const63;
        encoder_array[3].weights.norm2_beta = const64;

        encoder_array[4].weights.mhaQ_w = const65;
        encoder_array[4].weights.mhaQ_b = const66;
        encoder_array[4].weights.mhaK_w = const67;
        encoder_array[4].weights.mhaK_b = const68;
        encoder_array[4].weights.mhaV_w = const69;
        encoder_array[4].weights.mhaV_b = const70;
        encoder_array[4].weights.mhaO_w = const71;
        encoder_array[4].weights.mhaO_b = const72;
        encoder_array[4].weights.norm1_gamma = const77;
        encoder_array[4].weights.norm1_beta = const78;
        encoder_array[4].weights.ffn1_w = const73;
        encoder_array[4].weights.ffn1_b = const74;
        encoder_array[4].weights.ffn2_w = const75;
        encoder_array[4].weights.ffn2_b = const76;
        encoder_array[4].weights.norm2_gamma = const79;
        encoder_array[4].weights.norm2_beta = const80;

        encoder_array[5].weights.mhaQ_w = const81;
        encoder_array[5].weights.mhaQ_b = const82;
        encoder_array[5].weights.mhaK_w = const83;
        encoder_array[5].weights.mhaK_b = const84;
        encoder_array[5].weights.mhaV_w = const85;
        encoder_array[5].weights.mhaV_b = const86;
        encoder_array[5].weights.mhaO_w = const87;
        encoder_array[5].weights.mhaO_b = const88;
        encoder_array[5].weights.norm1_gamma = const93;
        encoder_array[5].weights.norm1_beta = const94;
        encoder_array[5].weights.ffn1_w = const89;
        encoder_array[5].weights.ffn1_b = const90;
        encoder_array[5].weights.ffn2_w = const91;
        encoder_array[5].weights.ffn2_b = const92;
        encoder_array[5].weights.norm2_gamma = const95;
        encoder_array[5].weights.norm2_beta = const96;

        for (uint i = 0; i < 6; i++)
        {
            decoder_block* decoder = &decoder_array[i];
            decoder->number = i;
            decoder->lmha1Q = (float**)createArray(22, 512, sizeof(float));
            decoder->lmha1K = (float**)createArray(22, 512, sizeof(float));
            decoder->lmha1V = (float**)createArray(22, 512, sizeof(float));
            decoder->lsat1QK = (float***)createArray(8, 22, 22, sizeof(float));
            decoder->lsoft1 = (float***)createArray(8, 22, 22, sizeof(float));
            decoder->lsat1SV = (float***)createArray(8, 22, 64, sizeof(float));
            decoder->lmha1O = (float**)createArray(22, 512, sizeof(float));
            decoder->lnorm1 = (float**)createArray(22, 512, sizeof(float));
            decoder->lmean1 = new float[22 * sizeof(float)];
            decoder->lvar1 = new float[22 * sizeof(float)];
            decoder->lmha2Q = (float**)createArray(22, 512, sizeof(float));
            decoder->lmha2K = (float**)createArray(22, 512, sizeof(float));
            decoder->lmha2V = (float**)createArray(22, 512, sizeof(float));
            decoder->lsat2QK = (float***)createArray(8, 22, 22, sizeof(float));
            decoder->lsoft2 = (float***)createArray(8, 22, 22, sizeof(float));
            decoder->lsat2SV = (float***)createArray(8, 22, 64, sizeof(float));
            decoder->lmha2O = (float**)createArray(22, 512, sizeof(float));
            decoder->lnorm2 = (float**)createArray(22, 512, sizeof(float));
            decoder->lmean2 = new float[22 * sizeof(float)];
            decoder->lvar2 = new float[22 * sizeof(float)];
            decoder->lffn1 = (float**)createArray(22, 1024, sizeof(float));
            decoder->lffn2 = (float**)createArray(22, 512, sizeof(float));
            decoder->lnorm3 = (float**)createArray(22, 512, sizeof(float));
            decoder->lmean3 = new float[22 * sizeof(float)];
            decoder->lvar3 = new float[22 * sizeof(float)];
            decoder->weights.number = i;
        }

        decoder_array[0].weights.mha1Q_w = const98;
        decoder_array[0].weights.mha1Q_b = const99;
        decoder_array[0].weights.mha1K_w = const100;
        decoder_array[0].weights.mha1K_b = const101;
        decoder_array[0].weights.mha1V_w = const102;
        decoder_array[0].weights.mha1V_b = const103;
        decoder_array[0].weights.mha1O_w = const104;
        decoder_array[0].weights.mha1O_b = const105;
        decoder_array[0].weights.norm1_gamma = const118;
        decoder_array[0].weights.norm1_beta = const119;
        decoder_array[0].weights.mha2Q_w = const106;
        decoder_array[0].weights.mha2Q_b = const107;
        decoder_array[0].weights.mha2K_w = const108;
        decoder_array[0].weights.mha2K_b = const109;
        decoder_array[0].weights.mha2V_w = const110;
        decoder_array[0].weights.mha2V_b = const111;
        decoder_array[0].weights.mha2O_w = const112;
        decoder_array[0].weights.mha2O_b = const113;
        decoder_array[0].weights.norm2_gamma = const120;
        decoder_array[0].weights.norm2_beta = const121;
        decoder_array[0].weights.ffn1_w = const114;
        decoder_array[0].weights.ffn1_b = const115;
        decoder_array[0].weights.ffn2_w = const116;
        decoder_array[0].weights.ffn2_b = const117;
        decoder_array[0].weights.norm3_gamma = const122;
        decoder_array[0].weights.norm3_beta = const123;

        decoder_array[1].weights.mha1Q_w = const124;
        decoder_array[1].weights.mha1Q_b = const125;
        decoder_array[1].weights.mha1K_w = const126;
        decoder_array[1].weights.mha1K_b = const127;
        decoder_array[1].weights.mha1V_w = const128;
        decoder_array[1].weights.mha1V_b = const129;
        decoder_array[1].weights.mha1O_w = const130;
        decoder_array[1].weights.mha1O_b = const131;
        decoder_array[1].weights.norm1_gamma = const144;
        decoder_array[1].weights.norm1_beta = const145;
        decoder_array[1].weights.mha2Q_w = const132;
        decoder_array[1].weights.mha2Q_b = const133;
        decoder_array[1].weights.mha2K_w = const134;
        decoder_array[1].weights.mha2K_b = const135;
        decoder_array[1].weights.mha2V_w = const136;
        decoder_array[1].weights.mha2V_b = const137;
        decoder_array[1].weights.mha2O_w = const138;
        decoder_array[1].weights.mha2O_b = const139;
        decoder_array[1].weights.norm2_gamma = const146;
        decoder_array[1].weights.norm2_beta = const147;
        decoder_array[1].weights.ffn1_w = const140;
        decoder_array[1].weights.ffn1_b = const141;
        decoder_array[1].weights.ffn2_w = const142;
        decoder_array[1].weights.ffn2_b = const143;
        decoder_array[1].weights.norm3_gamma = const148;
        decoder_array[1].weights.norm3_beta = const149;

        decoder_array[2].weights.mha1Q_w = const150;
        decoder_array[2].weights.mha1Q_b = const151;
        decoder_array[2].weights.mha1K_w = const152;
        decoder_array[2].weights.mha1K_b = const153;
        decoder_array[2].weights.mha1V_w = const154;
        decoder_array[2].weights.mha1V_b = const155;
        decoder_array[2].weights.mha1O_w = const156;
        decoder_array[2].weights.mha1O_b = const157;
        decoder_array[2].weights.norm1_gamma = const170;
        decoder_array[2].weights.norm1_beta = const171;
        decoder_array[2].weights.mha2Q_w = const158;
        decoder_array[2].weights.mha2Q_b = const159;
        decoder_array[2].weights.mha2K_w = const160;
        decoder_array[2].weights.mha2K_b = const161;
        decoder_array[2].weights.mha2V_w = const162;
        decoder_array[2].weights.mha2V_b = const163;
        decoder_array[2].weights.mha2O_w = const164;
        decoder_array[2].weights.mha2O_b = const165;
        decoder_array[2].weights.norm2_gamma = const172;
        decoder_array[2].weights.norm2_beta = const173;
        decoder_array[2].weights.ffn1_w = const166;
        decoder_array[2].weights.ffn1_b = const167;
        decoder_array[2].weights.ffn2_w = const168;
        decoder_array[2].weights.ffn2_b = const169;
        decoder_array[2].weights.norm3_gamma = const174;
        decoder_array[2].weights.norm3_beta = const175;

        decoder_array[3].weights.mha1Q_w = const176;
        decoder_array[3].weights.mha1Q_b = const177;
        decoder_array[3].weights.mha1K_w = const178;
        decoder_array[3].weights.mha1K_b = const179;
        decoder_array[3].weights.mha1V_w = const180;
        decoder_array[3].weights.mha1V_b = const181;
        decoder_array[3].weights.mha1O_w = const182;
        decoder_array[3].weights.mha1O_b = const183;
        decoder_array[3].weights.norm1_gamma = const196;
        decoder_array[3].weights.norm1_beta = const197;
        decoder_array[3].weights.mha2Q_w = const184;
        decoder_array[3].weights.mha2Q_b = const185;
        decoder_array[3].weights.mha2K_w = const186;
        decoder_array[3].weights.mha2K_b = const187;
        decoder_array[3].weights.mha2V_w = const188;
        decoder_array[3].weights.mha2V_b = const189;
        decoder_array[3].weights.mha2O_w = const190;
        decoder_array[3].weights.mha2O_b = const191;
        decoder_array[3].weights.norm2_gamma = const198;
        decoder_array[3].weights.norm2_beta = const199;
        decoder_array[3].weights.ffn1_w = const192;
        decoder_array[3].weights.ffn1_b = const193;
        decoder_array[3].weights.ffn2_w = const194;
        decoder_array[3].weights.ffn2_b = const195;
        decoder_array[3].weights.norm3_gamma = const200;
        decoder_array[3].weights.norm3_beta = const201;

        decoder_array[4].weights.mha1Q_w = const202;
        decoder_array[4].weights.mha1Q_b = const203;
        decoder_array[4].weights.mha1K_w = const204;
        decoder_array[4].weights.mha1K_b = const205;
        decoder_array[4].weights.mha1V_w = const206;
        decoder_array[4].weights.mha1V_b = const207;
        decoder_array[4].weights.mha1O_w = const208;
        decoder_array[4].weights.mha1O_b = const209;
        decoder_array[4].weights.norm1_gamma = const222;
        decoder_array[4].weights.norm1_beta = const223;
        decoder_array[4].weights.mha2Q_w = const210;
        decoder_array[4].weights.mha2Q_b = const211;
        decoder_array[4].weights.mha2K_w = const212;
        decoder_array[4].weights.mha2K_b = const213;
        decoder_array[4].weights.mha2V_w = const214;
        decoder_array[4].weights.mha2V_b = const215;
        decoder_array[4].weights.mha2O_w = const216;
        decoder_array[4].weights.mha2O_b = const217;
        decoder_array[4].weights.norm2_gamma = const224;
        decoder_array[4].weights.norm2_beta = const225;
        decoder_array[4].weights.ffn1_w = const218;
        decoder_array[4].weights.ffn1_b = const219;
        decoder_array[4].weights.ffn2_w = const220;
        decoder_array[4].weights.ffn2_b = const221;
        decoder_array[4].weights.norm3_gamma = const226;
        decoder_array[4].weights.norm3_beta = const227;

        decoder_array[5].weights.mha1Q_w = const228;
        decoder_array[5].weights.mha1Q_b = const229;
        decoder_array[5].weights.mha1K_w = const230;
        decoder_array[5].weights.mha1K_b = const231;
        decoder_array[5].weights.mha1V_w = const232;
        decoder_array[5].weights.mha1V_b = const233;
        decoder_array[5].weights.mha1O_w = const234;
        decoder_array[5].weights.mha1O_b = const235;
        decoder_array[5].weights.norm1_gamma = const248;
        decoder_array[5].weights.norm1_beta = const249;
        decoder_array[5].weights.mha2Q_w = const236;
        decoder_array[5].weights.mha2Q_b = const237;
        decoder_array[5].weights.mha2K_w = const238;
        decoder_array[5].weights.mha2K_b = const239;
        decoder_array[5].weights.mha2V_w = const240;
        decoder_array[5].weights.mha2V_b = const241;
        decoder_array[5].weights.mha2O_w = const242;
        decoder_array[5].weights.mha2O_b = const243;
        decoder_array[5].weights.norm2_gamma = const250;
        decoder_array[5].weights.norm2_beta = const251;
        decoder_array[5].weights.ffn1_w = const244;
        decoder_array[5].weights.ffn1_b = const245;
        decoder_array[5].weights.ffn2_w = const246;
        decoder_array[5].weights.ffn2_b = const247;
        decoder_array[5].weights.norm3_gamma = const252;
        decoder_array[5].weights.norm3_beta = const253;
    }


    ~jp2eng()
    {
        freeArray(3229, 512, const0);
        freeArray(512, 512, const1);
        freeArray(512, const2);
        freeArray(512, 512, const3);
        freeArray(512, const4);
        freeArray(512, 512, const5);
        freeArray(512, const6);
        freeArray(512, 512, const7);
        freeArray(512, const8);
        freeArray(512, 1024, const9);
        freeArray(1024, const10);
        freeArray(1024, 512, const11);
        freeArray(512, const12);
        freeArray(512, const13);
        freeArray(512, const14);
        freeArray(512, const15);
        freeArray(512, const16);
        freeArray(512, 512, const17);
        freeArray(512, const18);
        freeArray(512, 512, const19);
        freeArray(512, const20);
        freeArray(512, 512, const21);
        freeArray(512, const22);
        freeArray(512, 512, const23);
        freeArray(512, const24);
        freeArray(512, 1024, const25);
        freeArray(1024, const26);
        freeArray(1024, 512, const27);
        freeArray(512, const28);
        freeArray(512, const29);
        freeArray(512, const30);
        freeArray(512, const31);
        freeArray(512, const32);
        freeArray(512, 512, const33);
        freeArray(512, const34);
        freeArray(512, 512, const35);
        freeArray(512, const36);
        freeArray(512, 512, const37);
        freeArray(512, const38);
        freeArray(512, 512, const39);
        freeArray(512, const40);
        freeArray(512, 1024, const41);
        freeArray(1024, const42);
        freeArray(1024, 512, const43);
        freeArray(512, const44);
        freeArray(512, const45);
        freeArray(512, const46);
        freeArray(512, const47);
        freeArray(512, const48);
        freeArray(512, 512, const49);
        freeArray(512, const50);
        freeArray(512, 512, const51);
        freeArray(512, const52);
        freeArray(512, 512, const53);
        freeArray(512, const54);
        freeArray(512, 512, const55);
        freeArray(512, const56);
        freeArray(512, 1024, const57);
        freeArray(1024, const58);
        freeArray(1024, 512, const59);
        freeArray(512, const60);
        freeArray(512, const61);
        freeArray(512, const62);
        freeArray(512, const63);
        freeArray(512, const64);
        freeArray(512, 512, const65);
        freeArray(512, const66);
        freeArray(512, 512, const67);
        freeArray(512, const68);
        freeArray(512, 512, const69);
        freeArray(512, const70);
        freeArray(512, 512, const71);
        freeArray(512, const72);
        freeArray(512, 1024, const73);
        freeArray(1024, const74);
        freeArray(1024, 512, const75);
        freeArray(512, const76);
        freeArray(512, const77);
        freeArray(512, const78);
        freeArray(512, const79);
        freeArray(512, const80);
        freeArray(512, 512, const81);
        freeArray(512, const82);
        freeArray(512, 512, const83);
        freeArray(512, const84);
        freeArray(512, 512, const85);
        freeArray(512, const86);
        freeArray(512, 512, const87);
        freeArray(512, const88);
        freeArray(512, 1024, const89);
        freeArray(1024, const90);
        freeArray(1024, 512, const91);
        freeArray(512, const92);
        freeArray(512, const93);
        freeArray(512, const94);
        freeArray(512, const95);
        freeArray(512, const96);
        freeArray(44337, 512, const97);
        freeArray(512, 512, const98);
        freeArray(512, const99);
        freeArray(512, 512, const100);
        freeArray(512, const101);
        freeArray(512, 512, const102);
        freeArray(512, const103);
        freeArray(512, 512, const104);
        freeArray(512, const105);
        freeArray(512, 512, const106);
        freeArray(512, const107);
        freeArray(512, 512, const108);
        freeArray(512, const109);
        freeArray(512, 512, const110);
        freeArray(512, const111);
        freeArray(512, 512, const112);
        freeArray(512, const113);
        freeArray(512, 1024, const114);
        freeArray(1024, const115);
        freeArray(1024, 512, const116);
        freeArray(512, const117);
        freeArray(512, const118);
        freeArray(512, const119);
        freeArray(512, const120);
        freeArray(512, const121);
        freeArray(512, const122);
        freeArray(512, const123);
        freeArray(512, 512, const124);
        freeArray(512, const125);
        freeArray(512, 512, const126);
        freeArray(512, const127);
        freeArray(512, 512, const128);
        freeArray(512, const129);
        freeArray(512, 512, const130);
        freeArray(512, const131);
        freeArray(512, 512, const132);
        freeArray(512, const133);
        freeArray(512, 512, const134);
        freeArray(512, const135);
        freeArray(512, 512, const136);
        freeArray(512, const137);
        freeArray(512, 512, const138);
        freeArray(512, const139);
        freeArray(512, 1024, const140);
        freeArray(1024, const141);
        freeArray(1024, 512, const142);
        freeArray(512, const143);
        freeArray(512, const144);
        freeArray(512, const145);
        freeArray(512, const146);
        freeArray(512, const147);
        freeArray(512, const148);
        freeArray(512, const149);
        freeArray(512, 512, const150);
        freeArray(512, const151);
        freeArray(512, 512, const152);
        freeArray(512, const153);
        freeArray(512, 512, const154);
        freeArray(512, const155);
        freeArray(512, 512, const156);
        freeArray(512, const157);
        freeArray(512, 512, const158);
        freeArray(512, const159);
        freeArray(512, 512, const160);
        freeArray(512, const161);
        freeArray(512, 512, const162);
        freeArray(512, const163);
        freeArray(512, 512, const164);
        freeArray(512, const165);
        freeArray(512, 1024, const166);
        freeArray(1024, const167);
        freeArray(1024, 512, const168);
        freeArray(512, const169);
        freeArray(512, const170);
        freeArray(512, const171);
        freeArray(512, const172);
        freeArray(512, const173);
        freeArray(512, const174);
        freeArray(512, const175);
        freeArray(512, 512, const176);
        freeArray(512, const177);
        freeArray(512, 512, const178);
        freeArray(512, const179);
        freeArray(512, 512, const180);
        freeArray(512, const181);
        freeArray(512, 512, const182);
        freeArray(512, const183);
        freeArray(512, 512, const184);
        freeArray(512, const185);
        freeArray(512, 512, const186);
        freeArray(512, const187);
        freeArray(512, 512, const188);
        freeArray(512, const189);
        freeArray(512, 512, const190);
        freeArray(512, const191);
        freeArray(512, 1024, const192);
        freeArray(1024, const193);
        freeArray(1024, 512, const194);
        freeArray(512, const195);
        freeArray(512, const196);
        freeArray(512, const197);
        freeArray(512, const198);
        freeArray(512, const199);
        freeArray(512, const200);
        freeArray(512, const201);
        freeArray(512, 512, const202);
        freeArray(512, const203);
        freeArray(512, 512, const204);
        freeArray(512, const205);
        freeArray(512, 512, const206);
        freeArray(512, const207);
        freeArray(512, 512, const208);
        freeArray(512, const209);
        freeArray(512, 512, const210);
        freeArray(512, const211);
        freeArray(512, 512, const212);
        freeArray(512, const213);
        freeArray(512, 512, const214);
        freeArray(512, const215);
        freeArray(512, 512, const216);
        freeArray(512, const217);
        freeArray(512, 1024, const218);
        freeArray(1024, const219);
        freeArray(1024, 512, const220);
        freeArray(512, const221);
        freeArray(512, const222);
        freeArray(512, const223);
        freeArray(512, const224);
        freeArray(512, const225);
        freeArray(512, const226);
        freeArray(512, const227);
        freeArray(512, 512, const228);
        freeArray(512, const229);
        freeArray(512, 512, const230);
        freeArray(512, const231);
        freeArray(512, 512, const232);
        freeArray(512, const233);
        freeArray(512, 512, const234);
        freeArray(512, const235);
        freeArray(512, 512, const236);
        freeArray(512, const237);
        freeArray(512, 512, const238);
        freeArray(512, const239);
        freeArray(512, 512, const240);
        freeArray(512, const241);
        freeArray(512, 512, const242);
        freeArray(512, const243);
        freeArray(512, 1024, const244);
        freeArray(1024, const245);
        freeArray(1024, 512, const246);
        freeArray(512, const247);
        freeArray(512, const248);
        freeArray(512, const249);
        freeArray(512, const250);
        freeArray(512, const251);
        freeArray(512, const252);
        freeArray(512, const253);
        freeArray(512, 44337, const254);
        freeArray(44337, const255);

        freeArray(22, 22, encoderMask);
        freeArray(22, 22, decoderTargetMask);

        // layers

        freeArray(22, 512, encoder_in);
        freeArray(22, 512, decoder_in);
        freeArray(22, 44337, final_out);

        for (int i = 0; i < 6; i++)
        {
            encoder_block* encoder = &encoder_array[i];
            freeArray(22, 512, encoder->lmhaQ);
            freeArray(22, 512, encoder->lmhaK);
            freeArray(22, 512, encoder->lmhaV);
            freeArray(8, 22, 22, encoder->lsatQK);
            freeArray(8, 22, 22, encoder->lsoft);
            freeArray(8, 22, 64, encoder->lsatSV);
            freeArray(22, 512, encoder->lmhaO);
            delete[] encoder->lmean1;
            delete[] encoder->lvar1;
            freeArray(22, 512, encoder->lnorm1);
            freeArray(22, 1024, encoder->lffn1);
            freeArray(22, 512, encoder->lffn2);
            delete[] encoder->lmean2;
            delete[] encoder->lvar2;
            freeArray(22, 512, encoder->lnorm2);
        }

        for (uint i = 0; i < 6; i++)
        {
            decoder_block* decoder = &decoder_array[i];
            freeArray(22, 512, decoder->lmha1Q);
            freeArray(22, 512, decoder->lmha1K);
            freeArray(22, 512, decoder->lmha1V);
            freeArray(8, 22, 22, decoder->lsat1QK);
            freeArray(8, 22, 22, decoder->lsoft1);
            freeArray(8, 22, 64, decoder->lsat1SV);
            freeArray(22, 512, decoder->lmha1O);
            freeArray(22, 512, decoder->lnorm1);
            delete[] decoder->lmean1;
            delete[] decoder->lvar1;
            freeArray(22, 512, decoder->lmha2Q);
            freeArray(22, 512, decoder->lmha2K);
            freeArray(22, 512, decoder->lmha2V);
            freeArray(8, 22, 22, decoder->lsat2QK);
            freeArray(8, 22, 22, decoder->lsoft2);
            freeArray(8, 22, 64, decoder->lsat2SV);
            freeArray(22, 512, decoder->lmha2O);
            freeArray(22, 512, decoder->lnorm2);
            delete[] decoder->lmean2;
            delete[] decoder->lvar2;
            freeArray(22, 1024, decoder->lffn1);
            freeArray(22, 512, decoder->lffn2);
            freeArray(22, 512, decoder->lnorm3);
            delete[] decoder->lmean3;
            delete[] decoder->lvar3;
        }
    }

    ///*
    //    in: string
    //    out: string encoded as uints based on word mapping
    //*/
    //uint* text2seq(std::wstring input)
    //{
    //    // max length is 22
    //    uint* seqArray = (uint*)calloc(22, sizeof(uint));
    //    if (NULL == seqArray) exit(-1);

    //    seqArray[0] = 1; // SOS
    //    uint c = 0;
    //    for (; c < input.length() && c < 22; c++)
    //    {
    //        std::wstring wc = input.substr(c, 1);
    //        std::wcout << wc << std::endl;
    //        uint val = jpMap[wc];
    //    }
    //    seqArray[c] = 2; // EOS

    //    return seqArray;
    //}


    /*
        in:
        seq - encoded string sequence

        out:
        encMask - mask -1000000000.0 to anything in the array that's not a word
    */
    void createEncoderMask(uint* seq, float** encMask)
    {
        // max length is 22
        for (uint i = 0; i < 22; i++)
        {
            for (uint j = 0; j < 22; j++)
            {
                encMask[i][j] = seq[j] == 0 ? -1e9f : 0.0f;
            }
        }
    }

    /*
        in:
        seq - encoded string sequence

        out:
        decTargetMask - mask future tokens in the decoder
    */
    void createTargetMask(uint* seq, float** decTargetMask)
    {
        // max length is 22
        for (uint i = 0; i < 22; i++)
        {
            for (uint j = 0; j < 22; j++)
            {
                // mask sentence
                decTargetMask[i][j] = seq[j] == 0 ? -1e9f : 0.0f;
                // mask look ahead at target sequence
                float targetMask = (j <= i) ? 0.0f : -1e9f;
                decTargetMask[i][j] = fminf(decTargetMask[i][j], targetMask);
            }
        }
    }

    /*
        in:
        pos - current word
        i - current embedding vector index
        d_model - model depth

        out:
        the positional encoding for the given token
    */
    float positional_encoding(uint pos, uint i, uint d_model)
    {
        //angle_rates = 1 / np.power(10000, (2 * (i//2)) / np.float32(d_model))
        //return pos * angle_rates
        float angle_rates = 1.0f / powf(10000.0f, 2 * (i / 2) / float(d_model)) * pos;
        //apply sin to even indices in the array; 2i
        //apply cos to odd indices in the array; 2i + 1
        float encode = i % 2 == 0 ? sinf(angle_rates) : cosf(angle_rates);
        return encode;
    }

    /*
        in:
        in - input layer
        depth - d_model / # of heads, in this example 8 heads, 512 / 8 = 64
        ix, iy, iz - xyz input

        out:
        maps the 3d inputs to 2d array
    */
    float get_split_heads(float** in, uint depth, uint ix, uint iy, uint iz)
    {
        return in[iy][ix * depth + iz];
    }

    /*
        Remap 2d access to 3d outputs of attention weights layers

        in:
        in - input layer
        depth - d_model / # of heads, in this example 8 heads, 512 / 8 = 64
        ix, iy - xy input

        out:
        swap ix, iy for transpose, split 2 indices into 3
    */
    float get_sat_reshape(float*** in, uint depth, uint ix, uint iy)
    {
        uint x = ix;
        uint y = iy / depth;
        uint z = iy % depth;
        return in[y][x][z];
    }

    void embeddingLayer(float** cl, float** cw, uint* pl, uint l_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            cl[k][l] = cw[pl[k]][l] * sqrtf(l_max); // scaling factor
            cl[k][l] += positional_encoding(k, l, l_max);
        }
    }

    void denseLayer(float** cl, float** cw, float* cb, float** pl, uint l_max, uint m_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            cl[k][l] = 0.0f;
            // weights
            for (uint m = 0; m < m_max; m++)
            {
                cl[k][l] += pl[k][m] * cw[m][l];
            }

            // bias
            cl[k][l] += cb[l];
        }
    }

    void denseLayerRELU(float** cl, float** cw, float* cb, float** pl, uint l_max, uint m_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            cl[k][l] = 0.0f;
            // weights
            for (uint m = 0; m < m_max; m++)
            {
                cl[k][l] += pl[k][m] * cw[m][l];
            }

            // bias
            cl[k][l] += cb[l];

            // relu
            cl[k][l] = cl[k][l] > 0.0f ? cl[k][l] : 0.0f;
        }
    }

    void attentionQKLayer(float*** cl, float** lq, float** lk, float** mask,
        uint l_max, uint m_max, uint n_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            for (uint m = 0; m < m_max; m++)
            {
                cl[k][l][m] = 0.0f;
                // q * k.transpose
                for (uint n = 0; n < n_max; n++)
                {
                    cl[k][l][m] += get_split_heads(lq, 64, k, l, n) * get_split_heads(lk, 64, k, m, n);
                }
                // scale by length of v.shape[-1], last dimension of v
                cl[k][l][m] /= sqrtf(n_max);
                // mask
                cl[k][l][m] += mask[l][m];
            }
        }
    }

    void softmaxLayer(float*** cl, float*** pl, uint l_max, uint m_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            for (uint m = 0; m < m_max; m++)
            {
                float sum_exp = 0.0f;
                for (uint n = 0; n < m_max; n++)
                {
                    sum_exp += expf(pl[k][l][n]);
                }

                cl[k][l][m] = expf(pl[k][l][m]) / sum_exp;
            }
        }
    }

    void attentionSVLayer(float*** cl, float** lv, float*** pl,
        uint l_max, uint m_max, uint n_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            for (uint m = 0; m < m_max; m++)
            {
                cl[k][l][m] = 0.0f;
                // softmax * v
                for (uint n = 0; n < n_max; n++)
                {
                    cl[k][l][m] += pl[k][l][n] * get_split_heads(lv, 64, k, n, m);
                }
            }
        }
    }

    void multiHeadAttentionLayer(float** cl, float** cw, float* cb, float*** pl,
        uint l_max, uint m_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            cl[k][l] = 0.0f;
            // weights
            for (uint m = 0; m < m_max; m++)
            {
                cl[k][l] += get_sat_reshape(pl, 64, k, m) * cw[m][l];
            }

            // bias
            cl[k][l] += cb[l];
        }
    }

    void getMeanVariance(float** cl, float** pl, float* mean, float* var, uint l_max, uint m_max)
    {
        for (uint l = 0; l < l_max; l++)
        {
            mean[l] = 0.0f;
            var[l] = 0.0f;

            for (uint m = 0; m < m_max; m++)
            {
                mean[l] += cl[l][m] + pl[l][m];
            }

            mean[l] /= float(m_max);

            for (uint m = 0; m < m_max; m++)
            {
                var[l] += powf(cl[l][m] + pl[l][m] - mean[l], 2);
            }

            var[l] /= float(m_max);
        }
    }

    void normalizeLayer(float** cl, float* me, float* var, float* ga, float* be, float** pl, float** pl2,
        uint l_max, uint k)
    {
        for (uint l = 0; l < l_max; l++)
        {
            cl[k][l] = (pl[k][l] + pl2[k][l] - me[k]) / sqrtf(var[k] + epsilon);
            cl[k][l] = cl[k][l] * ga[l] + be[l];
        }
    }

    void forwardProp(uint* input)
    {
        using namespace std;

        //uint* seqIn = text2seq(input);
        uint* seqIn = input;

        createEncoderMask(seqIn, encoderMask);

        for (uint i = 0; i < 22; i++)
        {
            cout << seqIn[i] << " ";
        }
        cout << endl;

        vector<thread> threads;

        // embedding + scale layer + positional encode
        for (uint k = 0; k < 22; k++) {
            thread t(&jp2eng::embeddingLayer, this, encoder_in, const0, seqIn, 512, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();


        // 6 encoder layers
        for (int c = 0; c < 6; c++)
        {
            encoder_block encoder = encoder_array[c];
            // multi head attention, encoder head_q
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::denseLayer, this, encoder.lmhaQ, encoder.weights.mhaQ_w,
                    encoder.weights.mhaQ_b, encoder_in, 512, 512, k);
                threads.push_back(move(t));
            }

            // multi head attention, encoder head_k
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::denseLayer, this, encoder.lmhaK, encoder.weights.mhaK_w,
                    encoder.weights.mhaK_b, encoder_in, 512, 512, k);
                threads.push_back(move(t));
            }

            // multi head attention, encoder head_v
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::denseLayer, this, encoder.lmhaV, encoder.weights.mhaV_w,
                    encoder.weights.mhaV_b, encoder_in, 512, 512, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // scaled attention step q * k, encoder head
            for (uint k = 0; k < 8; k++) {
                thread t(&jp2eng::attentionQKLayer, this, encoder.lsatQK, encoder.lmhaQ,
                    encoder.lmhaK, encoderMask, 22, 22, 64, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // scaled attention step softmax, encoder head
            for (uint k = 0; k < 8; k++) {
                thread t(&jp2eng::softmaxLayer, this, encoder.lsoft, encoder.lsatQK, 22, 22, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // scaled attention step soft * v, encoder head
            for (uint k = 0; k < 8; k++) {
                thread t(&jp2eng::attentionSVLayer, this, encoder.lsatSV, encoder.lmhaV,
                    encoder.lsoft, 22, 64, 22, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // multi head attention, encoder head_dense_out
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::multiHeadAttentionLayer, this, encoder.lmhaO, encoder.weights.mhaO_w,
                    encoder.weights.mhaO_b, encoder.lsatSV, 512, 512, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            getMeanVariance(encoder.lmhaO, encoder_in, encoder.lmean1, encoder.lvar1, 22, 512);

            // encoder normalize layer 1
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::normalizeLayer, this, encoder.lnorm1, encoder.lmean1, encoder.lvar1,
                    encoder.weights.norm1_gamma, encoder.weights.norm1_beta, encoder.lmhaO, encoder_in, 512, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // point_wise_feed_forward_network 1, encoder head
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::denseLayerRELU, this, encoder.lffn1, encoder.weights.ffn1_w,
                    encoder.weights.ffn1_b, encoder.lnorm1, 1024, 512, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // point_wise_feed_forward_network 2, encoder head
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::denseLayer, this, encoder.lffn2, encoder.weights.ffn2_w,
                    encoder.weights.ffn2_b, encoder.lffn1, 512, 1024, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            getMeanVariance(encoder.lffn2, encoder.lnorm1, encoder.lmean2, encoder.lvar2, 22, 512);

            // encoder normalize layer 2
            for (uint k = 0; k < 22; k++) {
                thread t(&jp2eng::normalizeLayer, this, encoder.lnorm2, encoder.lmean2, encoder.lvar2,
                    encoder.weights.norm2_gamma, encoder.weights.norm2_beta, encoder.lffn2, encoder.lnorm1, 512, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // copy output back into input
            for (uint k = 0; k < 22; k++)
            {
                memcpy(encoder_in[k], encoder.lnorm2[k], sizeof(float) * 512);
            }
            //cout << encoder.lnorm2[21][500] << endl;
        }

        // decoder

        uint* seqOut = new uint[22 * sizeof(uint*)];
        for (uint i = 0; i < 22; i++) seqOut[i] = 0;
        seqOut[0] = 2; // SOS
        uint seqOutLen = 1; // Keep track of the sentence length
        uint predict_id = 0;

        //uint debugSeq[18] = { 1, 35, 3, 238, 134, 4, 110, 239, 37, 42, 65, 54, 42, 8, 6, 14, 29, 32 };
        //for (uint i = 0; i < 18; i++) seqOut[i] = debugSeq[i];
        //seqOutLen = 18;

        while (predict_id != 1 && seqOutLen <= 22)
        {
            createTargetMask(seqOut, decoderTargetMask);

            // embedding + scale layer + positional encode
            for (uint k = 0; k < seqOutLen; k++) {
                thread t(&jp2eng::embeddingLayer, this, decoder_in, const97, seqOut, 512, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            // 6 decoder layers
            for (int c = 0; c < 6; c++)
            {
                decoder_block decoder = decoder_array[c];

                // multi head attention, decoder head_q
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::denseLayer, this, decoder.lmha1Q, decoder.weights.mha1Q_w,
                        decoder.weights.mha1Q_b, decoder_in, 512, 512, k);
                    threads.push_back(move(t));
                }

                // multi head attention, decoder head_k
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::denseLayer, this, decoder.lmha1K, decoder.weights.mha1K_w,
                        decoder.weights.mha1K_b, decoder_in, 512, 512, k);
                    threads.push_back(move(t));
                }

                // multi head attention, decoder head_v
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::denseLayer, this, decoder.lmha1V, decoder.weights.mha1V_w,
                        decoder.weights.mha1V_b, decoder_in, 512, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // scaled attention step q * k, decoder head
                for (uint k = 0; k < 8; k++) {
                    thread t(&jp2eng::attentionQKLayer, this, decoder.lsat1QK, decoder.lmha1Q,
                        decoder.lmha1K, decoderTargetMask, seqOutLen, seqOutLen, 64, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // scaled attention step softmax, decoder head
                for (uint k = 0; k < 8; k++) {
                    thread t(&jp2eng::softmaxLayer, this, decoder.lsoft1, decoder.lsat1QK, seqOutLen, seqOutLen, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // scaled attention step soft * v, decoder head
                for (uint k = 0; k < 8; k++) {
                    thread t(&jp2eng::attentionSVLayer, this, decoder.lsat1SV, decoder.lmha1V,
                        decoder.lsoft1, seqOutLen, 64, seqOutLen, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // multi head attention, decoder head_dense_out
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::multiHeadAttentionLayer, this, decoder.lmha1O, decoder.weights.mha1O_w,
                        decoder.weights.mha1O_b, decoder.lsat1SV, 512, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                getMeanVariance(decoder.lmha1O, decoder_in, decoder.lmean1, decoder.lvar1, seqOutLen, 512);

                // decoder normalize layer 1
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::normalizeLayer, this, decoder.lnorm1, decoder.lmean1, decoder.lvar1,
                        decoder.weights.norm1_gamma, decoder.weights.norm1_beta, decoder.lmha1O, decoder_in, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // multi head attention, decoder head_q
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::denseLayer, this, decoder.lmha2Q, decoder.weights.mha2Q_w,
                        decoder.weights.mha2Q_b, decoder.lnorm1, 512, 512, k);
                    threads.push_back(move(t));
                }

                // multi head attention, decoder head_k
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::denseLayer, this, decoder.lmha2K, decoder.weights.mha2K_w,
                        decoder.weights.mha2K_b, encoder_in, 512, 512, k);
                    threads.push_back(move(t));
                }

                // multi head attention, decoder head_v
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::denseLayer, this, decoder.lmha2V, decoder.weights.mha2V_w,
                        decoder.weights.mha2V_b, encoder_in, 512, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // scaled attention step q * k, decoder head
                for (uint k = 0; k < 8; k++) {
                    thread t(&jp2eng::attentionQKLayer, this, decoder.lsat2QK, decoder.lmha2Q,
                        decoder.lmha2K, encoderMask, seqOutLen, seqOutLen, 64, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // scaled attention step softmax, decoder head
                for (uint k = 0; k < 8; k++) {
                    thread t(&jp2eng::softmaxLayer, this, decoder.lsoft2, decoder.lsat2QK, seqOutLen, seqOutLen, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // scaled attention step soft * v, decoder head
                for (uint k = 0; k < 8; k++) {
                    thread t(&jp2eng::attentionSVLayer, this, decoder.lsat2SV, decoder.lmha2V,
                        decoder.lsoft2, seqOutLen, 64, seqOutLen, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // multi head attention, decoder head_dense_out
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::multiHeadAttentionLayer, this, decoder.lmha2O, decoder.weights.mha2O_w,
                        decoder.weights.mha2O_b, decoder.lsat2SV, 512, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                getMeanVariance(decoder.lmha2O, decoder.lnorm1, decoder.lmean2, decoder.lvar2, seqOutLen, 512);

                // decoder normalize layer 2
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::normalizeLayer, this, decoder.lnorm2, decoder.lmean2, decoder.lvar2,
                        decoder.weights.norm2_gamma, decoder.weights.norm2_beta, decoder.lmha2O, decoder.lnorm1, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // point_wise_feed_forward_network 1, decoder head
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::denseLayerRELU, this, decoder.lffn1, decoder.weights.ffn1_w,
                        decoder.weights.ffn1_b, decoder.lnorm2, 1024, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // point_wise_feed_forward_network 2, decoder head
                for (uint k = 0; k < 22; k++) {
                    thread t(&jp2eng::denseLayer, this, decoder.lffn2, decoder.weights.ffn2_w,
                        decoder.weights.ffn2_b, decoder.lffn1, 512, 1024, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                getMeanVariance(decoder.lffn2, decoder.lnorm2, decoder.lmean3, decoder.lvar3, seqOutLen, 512);

                // decoder normalize layer 3
                for (uint k = 0; k < seqOutLen; k++) {
                    thread t(&jp2eng::normalizeLayer, this, decoder.lnorm3, decoder.lmean3, decoder.lvar3,
                        decoder.weights.norm3_gamma, decoder.weights.norm3_beta, decoder.lffn2, decoder.lnorm2, 512, k);
                    threads.push_back(move(t));
                }
                for (auto& th : threads) th.join();
                threads.clear();

                // copy output back into input
                for (uint k = 0; k < 22; k++)
                {
                    memcpy(decoder_in[k], decoder.lnorm3[k], sizeof(float) * 512);
                }
                //cout << decoder.lnorm3[3][99] << endl;
            }

            // final dense output
            for (uint k = 0; k < seqOutLen; k++) {
                thread t(&jp2eng::denseLayer, this, final_out, const254, const255, decoder_in, 44337, 512, k);
                threads.push_back(move(t));
            }
            for (auto& th : threads) th.join();
            threads.clear();

            float predict_val = final_out[seqOutLen - 1][predict_id];
            for (uint i = 0; i < 44337; i++)
            {
                predict_id = predict_val < final_out[seqOutLen - 1][i] ? i : predict_id;
                predict_val = predict_val < final_out[seqOutLen - 1][i] ? final_out[seqOutLen - 1][i] : predict_val;
            }

            seqOut[seqOutLen] = predict_id;
            seqOutLen = seqOutLen + 1;
        }

        for (uint i = 0; i < 22; i++) {
            cout << seqOut[i] << " ";
        }
        cout << endl;

        for (uint i = 0; i < 22; i++) {
            cout << engMap[seqOut[i]] << " ";
        }
        cout << endl;

        //delete[] seqIn;
        delete[] seqOut;
    }
};

int main()
{
    SetConsoleOutputCP(CP_UTF8);
    std::string PATHWEIGHTS = "./jp2eng_weights.bytes";
    std::string PATHTEXT2SEQ = "./jp_text2seq.tsv";
    std::string PATHSEQ2TEXT = "./eng_seq2text.tsv";

    // input sentence = "ドアを開けて床に着く"
    // hard coded input cause unicode support in C++ sucks
    // as long as the network output works
    uint seqArray[22];
	uint debugSeq[12] = { 1, 99, 59, 10, 237, 41, 12, 757, 8, 329, 27, 2 };
	uint i = 0;
	for (; i < 12; i++) seqArray[i] = debugSeq[i];
	for (; i < 22; i++) seqArray[i] = 0;

    jp2eng translator = jp2eng(PATHWEIGHTS, PATHTEXT2SEQ, PATHSEQ2TEXT);
    translator.forwardProp(seqArray);

    getchar();
}