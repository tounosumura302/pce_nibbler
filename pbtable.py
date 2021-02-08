"""
鮫！鮫！鮫！
自機弾（青）の移動方向テーブル
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

# 15方向の角度テーブル
ddeg=90/15
rads0=[math.radians(ddeg*r) for r in range(-7,0)]
rads1=[math.radians(0)]
rads2=[math.radians(ddeg*r) for r in range(1,8)]

rads=rads0+rads1+rads2

# cos,sin 計算
coss=[int(math.cos(r)*256*8) for r in rads]
sins=[int(math.sin(r)*256*8) for r in rads]

# テーブル出力
# 1方向あたり3バイト
gendb(coss,0xff,0)
gendb(coss,0xff00,8)
gendb(coss,0xff0000,16)

gendb(sins,0xff,0)
gendb(sins,0xff00,8)
gendb(sins,0xff0000,16)
