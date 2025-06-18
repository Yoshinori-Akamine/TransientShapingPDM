# Dual-Side Transient Shaping Pulse Density Modulation<br>FF信号生成用コード

## サンプルコードからの変更箇所
- io_top.vhd（変更）
- pwm_if.vhd（変更）
- 20241210.c（ホストプログラム）

## ホストプログラム　変数リスト
- T_PDM_pulses:PDMの周期（半周期パルスの数）
- m：送電側パルススキップの数（半周期パルスの数）
- n：受電側パルススキップの数（半周期パルスの数）
- delay：半周期基準の遅延数（半周期の整数倍）

### 以下は変える必要ほぼなし
- freq_cnt：周波数カウンタ（100MHzクロック基準）
- dt：デッドタイムカウンタ（デフォルト：500nsとした）
- enable：イネーブル信号（いらない？）
- Uref,Vref,Wref：指令値（いらない？）

## 変数の流れ
**.c内**
1. T_PDM_pulses, m, n, delay(int型）をpe-viewで書き込み（デフォ：60,2,1,7）
2. それぞれの整数をaddr_tpdm,addr_t1,addr_t2,addr_tdに書き込む。IPFPGA()を利用。デフォルトは順に0X21,0X22,0X23,0X24
**io_top内**
3. 0X21-0X24はtpdm_reg,t1_reg,t2_reg,td_regに書き込まれる
4. u_pwm_ifというコンポーネント宣言において、それぞれTPDM,T1,T2,TDと接続される

---
## io_top.vhd
- 

---

## pwm_if.vhd
- スイッチへの指令（pwm_up-pwm_wn）はu_ref_bbを基準にduty0.5専用の信号を書いている。
- この時点では、フルパルスの信号が強制的に出る
- この後の処理で、パルススキップを実装
### pulse generator
- 受け取ったフルパルス駆動信号S1-S4に対し、
- 
