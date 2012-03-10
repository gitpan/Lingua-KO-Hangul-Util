use strict;
use warnings;
BEGIN { $| = 1; print "1..513\n"; }
my $count = 0;
sub ok ($;$) {
    my $p = my $r = shift;
    if (@_) {
	my $x = shift;
	$p = !defined $x ? !defined $r : !defined $r ? 0 : $r eq $x;
    }
    print $p ? "ok" : "not ok", ' ', ++$count, "\n";
}

use Lingua::KO::Hangul::Util qw(decomposeJamo composeJamo);

ok(1);

#########################

sub str2hex { join ' ', map sprintf("%04X", $_), unpack 'U*', shift }
sub hex2str { pack 'U*', map hex, split ' ', shift }

while (<DATA>) {
    next if !/\S/;
    chomp;
    my ($complex, $decomp) = split /\t/;
    ok(str2hex(decomposeJamo(hex2str($complex))), $decomp);
    ok(str2hex(composeJamo(hex2str($decomp))), $complex);
}

1;
__DATA__
1100	1100
1101	1100 1100
1102	1102
1103	1103
1104	1103 1103
1105	1105
1106	1106
1107	1107
1108	1107 1107
1109	1109
110A	1109 1109
110B	110B
110C	110C
110D	110C 110C
110E	110E
110F	110F
1110	1110
1111	1111
1112	1112
1113	1102 1100
1114	1102 1102
1115	1102 1103
1116	1102 1107
1117	1103 1100
1118	1105 1102
1119	1105 1105
111A	1105 1112
111B	1105 110B
111C	1106 1107
111D	1106 110B
111E	1107 1100
111F	1107 1102
1120	1107 1103
1121	1107 1109
1122	1107 1109 1100
1123	1107 1109 1103
1124	1107 1109 1107
1125	1107 1109 1109
1126	1107 1109 110C
1127	1107 110C
1128	1107 110E
1129	1107 1110
112A	1107 1111
112B	1107 110B
112C	1107 1107 110B
112D	1109 1100
112E	1109 1102
112F	1109 1103
1130	1109 1105
1131	1109 1106
1132	1109 1107
1133	1109 1107 1100
1134	1109 1109 1109
1135	1109 110B
1136	1109 110C
1137	1109 110E
1138	1109 110F
1139	1109 1110
113A	1109 1111
113B	1109 1112
113C	113C
113D	113C 113C
113E	113E
113F	113E 113E
1140	1140
1141	110B 1100
1142	110B 1103
1143	110B 1106
1144	110B 1107
1145	110B 1109
1146	110B 1140
1147	110B 110B
1148	110B 110C
1149	110B 110E
114A	110B 1110
114B	110B 1111
114C	114C
114D	110C 110B
114E	114E
114F	114E 114E
1150	1150
1151	1150 1150
1152	110E 110F
1153	110E 1112
1154	1154
1155	1155
1156	1111 1107
1157	1111 110B
1158	1112 1112
1159	1159
115A	115A
115B	115B
115C	115C
115D	115D
115E	115E
115F	115F
1160	1160
1161	1161
1162	1161 1175
1163	1163
1164	1163 1175
1165	1165
1166	1165 1175
1167	1167
1168	1167 1175
1169	1169
116A	1169 1161
116B	1169 1161 1175
116C	1169 1175
116D	116D
116E	116E
116F	116E 1165
1170	116E 1165 1175
1171	116E 1175
1172	1172
1173	1173
1174	1173 1175
1175	1175
1176	1161 1169
1177	1161 116E
1178	1163 1169
1179	1163 116D
117A	1165 1169
117B	1165 116E
117C	1165 1173
117D	1167 1169
117E	1167 116E
117F	1169 1165
1180	1169 1165 1175
1181	1169 1167 1175
1182	1169 1169
1183	1169 116E
1184	116D 1163
1185	116D 1163 1175
1186	116D 1167
1187	116D 1169
1188	116D 1175
1189	116E 1161
118A	116E 1161 1175
118B	116E 1165 1173
118C	116E 1167 1175
118D	116E 116E
118E	1172 1161
118F	1172 1165
1190	1172 1165 1175
1191	1172 1167
1192	1172 1167 1175
1193	1172 116E
1194	1172 1175
1195	1173 116E
1196	1173 1173
1197	1173 1175 116E
1198	1175 1161
1199	1175 1163
119A	1175 1169
119B	1175 116E
119C	1175 1173
119D	1175 119E
119E	119E
119F	119E 1165
11A0	119E 116E
11A1	119E 1175
11A2	119E 119E
11A3	11A3
11A4	11A4
11A5	11A5
11A6	11A6
11A7	11A7
11A8	11A8
11A9	11A8 11A8
11AA	11A8 11BA
11AB	11AB
11AC	11AB 11BD
11AD	11AB 11C2
11AE	11AE
11AF	11AF
11B0	11AF 11A8
11B1	11AF 11B7
11B2	11AF 11B8
11B3	11AF 11BA
11B4	11AF 11C0
11B5	11AF 11C1
11B6	11AF 11C2
11B7	11B7
11B8	11B8
11B9	11B8 11BA
11BA	11BA
11BB	11BA 11BA
11BC	11BC
11BD	11BD
11BE	11BE
11BF	11BF
11C0	11C0
11C1	11C1
11C2	11C2
11C3	11A8 11AF
11C4	11A8 11BA 11A8
11C5	11AB 11A8
11C6	11AB 11AE
11C7	11AB 11BA
11C8	11AB 11EB
11C9	11AB 11C0
11CA	11AE 11A8
11CB	11AE 11AF
11CC	11AF 11A8 11BA
11CD	11AF 11AB
11CE	11AF 11AE
11CF	11AF 11AE 11C2
11D0	11AF 11AF
11D1	11AF 11B7 11A8
11D2	11AF 11B7 11BA
11D3	11AF 11B8 11BA
11D4	11AF 11B8 11C2
11D5	11AF 11B8 11BC
11D6	11AF 11BA 11BA
11D7	11AF 11EB
11D8	11AF 11BF
11D9	11AF 11F9
11DA	11B7 11A8
11DB	11B7 11AF
11DC	11B7 11B8
11DD	11B7 11BA
11DE	11B7 11BA 11BA
11DF	11B7 11EB
11E0	11B7 11BE
11E1	11B7 11C2
11E2	11B7 11BC
11E3	11B8 11AF
11E4	11B8 11C1
11E5	11B8 11C2
11E6	11B8 11BC
11E7	11BA 11A8
11E8	11BA 11AE
11E9	11BA 11AF
11EA	11BA 11B8
11EB	11EB
11EC	11BC 11A8
11ED	11BC 11A8 11A8
11EE	11BC 11BC
11EF	11BC 11BF
11F0	11F0
11F1	11F0 11BA
11F2	11F0 11EB
11F3	11C1 11B8
11F4	11C1 11BC
11F5	11C2 11AB
11F6	11C2 11AF
11F7	11C2 11B7
11F8	11C2 11B8
11F9	11F9
11FA	11FA
11FB	11FB
11FC	11FC
11FD	11FD
11FE	11FE
11FF	11FF
