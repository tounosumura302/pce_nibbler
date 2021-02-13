"""
鮫！鮫！鮫！
移動方向テーブル
"""

import math

def gendb(lst,mask,shift):
    """
    .db ステートメント生成
    """
    s="    .db "
    for v in lst:
       s+="${:02x},".format((v&mask)>>shift)
    print(s[:len(s)-1])

# 32方向の角度テーブル
ddeg=360/32
rads0=[math.radians(180)]
rads1=[math.radians(ddeg*r+180) for r in range(1,8)]
rads2=[math.radians(270)]
rads3=[math.radians(ddeg*r+270) for r in range(1,8)]
rads4=[math.radians(0)]
rads5=[math.radians(ddeg*r+0) for r in range(1,8)]
rads6=[math.radians(90)]
rads7=[math.radians(ddeg*r+90) for r in range(1,8)]

rads=rads0+rads1+rads2+rads3+rads4+rads5+rads6+rads7

# cos,sin 計算
coss=[int(math.cos(r)*256) for r in rads]
sins=[int(math.sin(r)*256) for r in rads]

# テーブル出力
# 1方向あたり3バイト
gendb(coss,0xff,0)
gendb(coss,0xff00,8)
gendb(coss,0xff0000,16)

gendb(sins,0xff,0)
gendb(sins,0xff00,8)
gendb(sins,0xff0000,16)
