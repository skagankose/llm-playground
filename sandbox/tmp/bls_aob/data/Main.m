close all
clearvars
clc

veriyolu= '\\llfs\BLS\NSD\ORTAK\Test_Sistemleri\Performans_Testleri\2024_Veri\RS\TurNa-N\00163436_TurNa_NH\NH-53\Kalibrasyon_Kabul\20240824';
analysis_result_folder= 'C:\Users\onur.tanis\Desktop\Yapay_Zeka_Veri\Analiz';

list = string(ls(veriyolu));
pat = 'SART';
TF = contains(list,pat);
list_SART = strip(list(TF,:));

for part_veriyolu = list_SART'
% \NH_0053_Kalibrasyon_Kabul_20240824_KALIB_SART_00

tmp_veriyolu = fullfile(veriyolu, part_veriyolu);
tmp_pat = extract(tmp_veriyolu,"SART_" + digitsPattern(2));

[struct_data] = fcn_TurNa_N_RAW_parser_veri_csv(tmp_veriyolu);

new_struct_data.GYROX = struct_data(1).DELTATHETA';
new_struct_data.GYROY = struct_data(2).DELTATHETA';
new_struct_data.GYROZ = struct_data(3).DELTATHETA';
new_struct_data.ACCX = struct_data(1).ACC';
new_struct_data.ACCY = struct_data(2).ACC';
new_struct_data.ACCZ = struct_data(3).ACC';
new_struct_data.GYROTEMPSX1 = struct_data(1).GYROtemps';
new_struct_data.GYROTEMPSY1 = struct_data(2).GYROtemps';
new_struct_data.GYROTEMPSZ1 = struct_data(3).GYROtemps';
new_struct_data.GYROTEMPSX2 = struct_data(1).GYROtemps2';
new_struct_data.GYROTEMPSY2 = struct_data(2).GYROtemps2';
new_struct_data.GYROTEMPSZ2 = struct_data(3).GYROtemps2';
new_struct_data.BOARDTEMP= struct_data(1).BOARDtemp';
new_struct_data.GAIN= struct_data(1).GAIN';
new_struct_data.PINFET_POWER= struct_data(1).PINFET_POWER';
new_struct_data.PBFM= struct_data(1).PBFM';
new_struct_data.ASE_POWER= struct_data(1).ASE_POWER';
new_struct_data.ILASER= struct_data(1).ILASER';
new_struct_data.TLASER= struct_data(1).TLASER';
new_struct_data.TEC_CURRENT= struct_data(1).TEC_CURRENT';

T = struct2table(new_struct_data);
writetable(T,strcat(tmp_pat,'.txt'),'Delimiter','tab');

end