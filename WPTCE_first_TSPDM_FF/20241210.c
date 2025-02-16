#include <mwio4.h> // PE-Expert4専用ライブラリを利用するためのヘッダファイル

// FPGAのボード番号
#define BDN_FPGA 1 // FPGAボード (FPGAの制御)

// 固定の定数
#define INV_FREQ 85000.0 // キャリア周波数を浮動小数点に変更
#define DEAD_TIME 500        // デッドタイム (500ns)

// タイマー設定（単位: マイクロ秒）
#define TIMER0_INTERVAL 100000   // タイマー0の間隔（100 ms）

// 書き換え可能な変数（PE-Viewで後から変更可能）
volatile int T_PDM_pulses = 60; // PDMの周期（半周期パルスの数）
volatile int m = 2;              // 送電側パルススキップ（半周期パルスの数）
volatile int n = 1;              // 受電側パルススキップ（半周期パルスの数）
volatile int delay = 7;          // 遅延パルス数（半周期パルスの数）
volatile int freq_cnt = 588;     // 周波数のカウンタの値
volatile int dt = 50;           // デッドタイム（10ns単位）
volatile int enalbe = 0;         // 有効化
volatile int Uref = 294;
volatile int Vref = 294;
volatile int Wref = 294;

// FPGAレジスタのアドレス
#define addr_tpdm  0x20 // FPGAのアドレス (PDMの周期（時間）)
#define addr_t1    0x21 // FPGAのアドレス (送電側パルス時間)
#define addr_t2    0x22 // FPGAのアドレス (受電側パルス時間)
#define addr_td    0x23 // FPGAのアドレス (遅延パルス時間)
#define addr_freq_cnt  0x01 // FPGAのアドレス (周波数のカウンタ)
#define addr_deadtime  0x05 // FPGAのアドレス (デッドタイム)
#define addr_enable  0x06 // FPGAのアドレス (有効化)
#define addr_u_ref 0X02 // u
#define addr_v_ref 0X03 // v
#define addr_w_ref 0X04 // w


// 計算専用の変数（内部計算のみで更新）
int tpdm; // PDMの周期（時間、10ns単位）
int t1;   // 送電側パルス時間（10ns単位）
int t2;   // 受電側パルス時間(10ns単位)
int td;   // 遅延パルス時間（10ns単位）

// 計算専用変数を再計算する関数
// タイマーで定期的に呼び出す（割り込み）
void update_calculated_values(void)
{
    double tmp_tpdm, tmp_t1, tmp_t2, tmp_td; // 一時的な浮動小数点型変数を使用

    // tpdmの計算
    tmp_tpdm = (1.0 / INV_FREQ) / 2.0 * T_PDM_pulses * 1e8; // 浮動小数点演算
    tpdm = (int)tmp_tpdm; // 最終的にint型にキャスト、10ns単位の整数値

    // t1の計算
    tmp_t1 = (1.0 / INV_FREQ) / 2.0 * m * 1e8; // `m`を基に計算
    t1 = (int)tmp_t1;

    // t2の計算
    tmp_t2 = (1.0 / INV_FREQ) / 2.0 * n * 1e8; // `n`を基に計算
    t2 = (int)tmp_t2;

    // tdの計算
    tmp_td = (1.0 / INV_FREQ) / 2.0 * delay * 1e8; // `delay`を基に計算
    td = (int)tmp_td;
}

// FPGAに計算済みの値を書き込む関数
interrupt void write_to_fpga(void)
{
    // タイマー0のイベントフラグをクリアし、次の割り込みを有効化
    C6657_timer0_clear_eventflag();

    // 再計算を実施
    update_calculated_values();
    
    // tpdm（PDM周期の時間）をFPGAに書き込む
    IPFPGA_write(BDN_FPGA, addr_tpdm, T_PDM_pulses);
    
    // t1（送電側パルス時間）をFPGAに書き込む
    IPFPGA_write(BDN_FPGA, addr_t1, m);
    
    // t2（受電側パルス時間）をFPGAに書き込む
    IPFPGA_write(BDN_FPGA, addr_t2, n);
    
    // td（遅延パルス時間）をFPGAに書き込む
    IPFPGA_write(BDN_FPGA, addr_td, delay);

    IPFPGA_write(BDN_FPGA, addr_freq_cnt, freq_cnt);
    IPFPGA_write(BDN_FPGA, addr_deadtime, dt);
    IPFPGA_write(BDN_FPGA, addr_enable, enalbe);
	IPFPGA_write(BDN_FPGA, addr_u_ref, Uref);
	IPFPGA_write(BDN_FPGA, addr_v_ref, Vref);
	IPFPGA_write(BDN_FPGA, addr_w_ref, Wref);
}

void initialize(void)
{
    // 割り込みを一時無効化
    int_disable();

    // タイマー0の初期化
    C6657_timer0_init(TIMER0_INTERVAL);
    C6657_timer0_init_vector(write_to_fpga, (CSL_IntcVectId)6);
    C6657_timer0_start();
    C6657_timer0_enable_int();
    // 周波数をFPGAに書き込む
    // 割り込みを再度有効化
    int_enable();
}

// メイン関数
int MW_main(void)
{
    // 初期化処理（タイマーの設定）
    initialize();

    // 無限ループ
    while (1)
    {
        // 必要なら追加処理をここに記述
    }

    return 0; // 実際には到達しない
}