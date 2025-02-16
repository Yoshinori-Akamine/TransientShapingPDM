----------------------------------------------------------------------------------
-- Company: Myway Plus Corporation 
-- Module Name: pwm_if
-- Target Devices: Kintex-7 xc7k70t
-- Tool Versions: Vivado 2016.4
-- Create Date: 2017/01/10
-- Revision: 1.0
----------------------------------------------------------------------------------

-- ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ????????????????????????ｿｽﾙぼ抵ｿｽ?????????ｿｽﾌみ。?ｿｽﾅ鯉ｿｽ??????????ｿｽo?ｿｽ?ｿｽ??????????ｿｽ?ｿｽ??????????ｿｽﾏ撰ｿｽ?ｿｽﾌみ変更?????????
-- 1. pulse_generator?ｿｽﾌ?ｿｽ?ｿｽW?ｿｽ?ｿｽ?ｿｽ[?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ????????(?????????ｿｽﾔ会ｿｽ?????????deadtime_if?ｿｽﾌ会ｿｽ?ｿｽj?ｿｽ?ｿｽ??
-- 2. pulse_generator?ｿｽﾌコ?ｿｽ?ｿｽ?ｿｽ|??????????ｿｽl?ｿｽ?ｿｽ?ｿｽg?ｿｽ?ｿｽ?ｿｽ????????????????????????ｿｽA?ｿｽ[?ｿｽL?????????ｿｽN?ｿｽ`?ｿｽ?ｿｽ?ｿｽﾌ撰ｿｽ??????????????????????????????????ｿｽ?ｿｽ??
-- 3. pulse_generator?ｿｽﾌイ?ｿｽ?ｿｽ?ｿｽX?ｿｽ^?ｿｽ?ｿｽ?ｿｽX?ｿｽ?ｿｽ?ｿｽ????????????????pdm?ｿｽ?ｿｽ?????????????????ｿｽ?ｿｽ?ｿｽO?ｿｽﾅ、deadtime_if?ｿｽ?ｿｽ??????????ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽM?ｿｽ?ｿｽ?ｿｽﾉゑｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽﾄ暦ｿｽ?ｿｽp?ｿｽ?ｿｽ?ｿｽ?ｿｽ?????????ｿｽ?ｿｽ??????????ｿｽ?ｿｽ??
-- 4. pulse_generator?ｿｽ?ｿｽ?ｿｽ?????????ｿｽ?ｿｽ?ｿｽ?ｿｽﾛゑｿｽ?????????ｿｽv?ｿｽﾈ信?ｿｽ?ｿｽ?ｿｽﾌ撰ｿｽ????????????????u.v?ｿｽ?ｿｽ?ｿｽﾌス?ｿｽC?????????ｿｽ`?ｿｽ?ｿｽS1,S2,S3,S4?ｿｽﾆゑｿｽ?ｿｽﾄ暦ｿｽ?ｿｽp?ｿｽ?ｿｽ?ｿｽ?ｿｽB?ｿｽ?ｿｽ??

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;

entity pwm_if is
    port (
        CLK_IN           : in std_logic;
        RESET_IN        : in std_logic;
        nPWM_UP_OUT    : out std_logic; --nUSER_OPT_OUT(0)
        nPWM_UN_OUT    : out std_logic; --nUSER_OPT_OUT(1)
        nPWM_VP_OUT    : out std_logic; --nUSER_OPT_OUT(2)
        nPWM_VN_OUT    : out std_logic; --nUSER_OPT_OUT(3)
        nPWM_WP_OUT    : out std_logic; --nUSER_OPT_OUT(4)
        nPWM_WN_OUT    : out std_logic; --nUSER_OPT_OUT(5)
        nUSER_OPT_OUT : out std_logic_vector (23 downto 6);

        UPDATE    : in std_logic;
        CARRIER   : in std_logic_vector (15 downto 0);
        U_REF    : in std_logic_vector (15 downto 0);
        V_REF    : in std_logic_vector (15 downto 0);
        W_REF    : in std_logic_vector (15 downto 0);
        DEADTIME : in std_logic_vector (12 downto 0);
        GATE_EN  : in std_logic;
        
        -- ?ｿｽﾈ会ｿｽ?ｿｽ?ｿｽ????????????????
        TPDM : in std_logic_vector(31 downto 0);
        T1 : in std_logic_vector(31 downto 0);
        T2 : in std_logic_vector(31 downto 0);
        TD : in std_logic_vector(31 downto 0)
        -- ?ｿｽﾈ擾ｿｽ?ｿｽ????????????????
    );
end pwm_if;

architecture Behavioral of pwm_if is

    component deadtime_if is
        Port (
            CLK_IN     : in std_logic;
            RESET_IN : in std_logic;
            DT           : in std_logic_vector(12 downto 0);
            G_IN        : in std_logic;
            G_OUT      : out std_logic
        );
    end component;

-- 2. pulse_generator?ｿｽﾌコ?ｿｽ?ｿｽ?ｿｽ|??????????ｿｽl?ｿｽ?ｿｽ?ｿｽg?ｿｽ?ｿｽ?ｿｽ????????
    component pulse_generator is
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            TPDM_in    : in  std_logic_vector(31 downto 0); -- PDM?ｿｽ?ｿｽ????????
            T1_in      : in  std_logic_vector(31 downto 0); -- ?????????ｿｽd?ｿｽp?ｿｽ?ｿｽ?ｿｽX?ｿｽ?ｿｽ?ｿｽ?ｿｽ
            T2_in      : in  std_logic_vector(31 downto 0); -- ?ｿｽ?ｿｽd?ｿｽp?ｿｽ?ｿｽ?ｿｽX?ｿｽ?ｿｽ?ｿｽ?ｿｽ
            TD_in      : in  std_logic_vector(31 downto 0); -- ?????????ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ
            S1_in   : in  STD_LOGIC;
            S2_in   : in  STD_LOGIC;
            S3_in   : in  STD_LOGIC;
            S4_in   : in  STD_LOGIC;
            S5_in   : in  STD_LOGIC;
            S6_in   : in  STD_LOGIC;
            S1_out  : out STD_LOGIC;
            S2_out  : out STD_LOGIC;
            S3_out  : out STD_LOGIC;
            S4_out  : out STD_LOGIC;
            S5_out  : out STD_LOGIC;
            S6_out  : out STD_LOGIC
        );
    end component;

    signal carrier_cnt_max_b : std_logic_vector (15 downto 0);
    signal carrier_cnt_max_bb : std_logic_vector (15 downto 0);
    signal carrier_cnt       : std_logic_vector (15 downto 0); -- counter
    signal carrier_up_down : std_logic;
    signal u_ref_b : std_logic_vector (15 downto 0);
    signal v_ref_b : std_logic_vector (15 downto 0);
    signal w_ref_b : std_logic_vector (15 downto 0);
    signal u_ref_bb : std_logic_vector (15 downto 0);
    signal v_ref_bb : std_logic_vector (15 downto 0);
    signal w_ref_bb : std_logic_vector (15 downto 0);
    signal pwm_up : std_logic;
    signal pwm_un : std_logic;
    signal pwm_vp : std_logic;
    signal pwm_vn : std_logic;
    signal pwm_wp : std_logic;
    signal pwm_wn : std_logic; -- before deadtime_if component
    signal pwm_up_dt : std_logic := '0';
    signal pwm_un_dt : std_logic := '0';
    signal pwm_vp_dt : std_logic := '0';
    signal pwm_vn_dt : std_logic := '0';
    signal pwm_wp_dt : std_logic := '0';
    signal pwm_wn_dt : std_logic := '0'; -- after deadtime_if component / before pulse_generator component
    signal dt_b : std_logic_vector (12 downto 0);
    signal dt_bb : std_logic_vector (12 downto 0);
    signal gate_en_b : std_logic := '0';

    -- ?ｿｽ?ｿｽ?????????????????ｿｽﾌ信?ｿｽ?ｿｽ?ｿｽﾍ茨ｿｽ????????
    signal pwm_up_dt2 : std_logic := '0';
    signal pwm_un_dt2 : std_logic := '0';
    signal pwm_vp_dt2 : std_logic := '0';
    signal pwm_vn_dt2 : std_logic := '0';
    signal pwm_wp_dt2 : std_logic := '0'; 
    signal pwm_wn_dt2 : std_logic := '0'; -- after pulse_generator component
--    signal wp_delay_line : std_logic_vector(293 downto 0);
--    signal wn_delay_line : std_logic_vector(293 downto 0);
    

   -- attribute ?ｿｽﾌ撰ｿｽ????????
    attribute mark_debug : string;

    -- ?????????ｿｽM?ｿｽ?ｿｽ?ｿｽﾖの適?ｿｽp
    attribute mark_debug of pwm_up : signal is "true";
    attribute mark_debug of pwm_un : signal is "true";
    attribute mark_debug of pwm_vp : signal is "true";
    attribute mark_debug of pwm_vn : signal is "true";
    attribute mark_debug of pwm_wp : signal is "true";
    attribute mark_debug of pwm_wn : signal is "true";
--    attribute mark_debug of gate_en_b : signal is "true";
--    attribute mark_debug of carrier_cnt : signal is "true";
    attribute mark_debug of u_ref_b : signal is "true";
--    attribute mark_debug of v_ref_b : signal is "true";
--    attribute mark_debug of w_ref_b : signal is "true";
--    attribute mark_debug of carrier_cnt_max_b : signal is "true";
    attribute mark_debug of pwm_up_dt : signal is "true";
    attribute mark_debug of pwm_un_dt : signal is "true";
    attribute mark_debug of pwm_vp_dt : signal is "true";
    attribute mark_debug of pwm_vn_dt : signal is "true";
    attribute mark_debug of pwm_wp_dt : signal is "true";
    attribute mark_debug of pwm_wn_dt : signal is "true"; -- ?????ｿｽt?ｿｽH?ｿｽ?ｿｽ?ｿｽg??????ｿｽt?ｿｽ?ｿｽ?ｿｽp?ｿｽ?ｿｽ?ｿｽX?ｿｽM?ｿｽ?ｿｽ
    attribute mark_debug of pwm_up_dt2 : signal is "true";
    attribute mark_debug of pwm_un_dt2 : signal is "true";
    attribute mark_debug of pwm_vp_dt2 : signal is "true";
    attribute mark_debug of pwm_vn_dt2 : signal is "true";
    attribute mark_debug of pwm_wp_dt2 : signal is "true";
    attribute mark_debug of pwm_wn_dt2 : signal is "true"; -- pdm?ｿｽﾌ出?ｿｽﾍ信?ｿｽ?ｿｽ



begin

    process(CLK_IN)
    begin
        if CLK_IN'event and CLK_IN = '1' then
            if RESET_IN = '1' then
                gate_en_b <= '0';
            else
                gate_en_b <= GATE_EN; 
            end if;

            if RESET_IN = '1' then
                carrier_cnt_max_b  <= X"1388"; -- 10kHz
                carrier_cnt        <= X"0000";
                u_ref_b <= X"09C4"; -- m = 0.5
                v_ref_b <= X"09C4"; -- m = 0.5
                w_ref_b <= X"09C4"; -- m = 0.5
                dt_b <= '0' & X"190"; -- 4us
            elsif UPDATE = '1' then
                carrier_cnt_max_b <= CARRIER;
                u_ref_b <= U_REF;
                v_ref_b <= V_REF;
                w_ref_b <= W_REF;
                dt_b <= DEADTIME;
            end if;       

            if RESET_IN = '1' then
                carrier_up_down <= '1';
                carrier_cnt_max_bb <= X"1388";
            elsif carrier_cnt = X"0001" and carrier_up_down = '0' then
                carrier_up_down <= '1';
            elsif carrier_cnt >= (carrier_cnt_max_bb -1) and carrier_up_down = '1' then
                carrier_up_down <= '0';
                carrier_cnt_max_bb <= carrier_cnt_max_b;
            end if;

            if RESET_IN = '1' then
                carrier_cnt <= X"0000";
            elsif carrier_up_down = '1' then
                carrier_cnt <= carrier_cnt + 1;
            else
                carrier_cnt <= carrier_cnt - 1;
            end if;   

        end if;
    end process;

    process(CLK_IN)
    begin
        if CLK_IN'event and CLK_IN = '1' then
            if RESET_IN = '1' then
                u_ref_bb <= X"09C4"; -- m = 0.5
                v_ref_bb <= X"09C4"; -- m = 0.5
                w_ref_bb <= X"09C4"; -- m = 0.5
            elsif carrier_cnt = (carrier_cnt_max_bb -1) and carrier_up_down = '1' then
                u_ref_bb <= u_ref_b;
                v_ref_bb <= v_ref_b;
                w_ref_bb <= w_ref_b;
            end if;

            if RESET_IN = '1' then
                pwm_up <= '0';
                pwm_un <= '0';
                pwm_vp <= '0';
                pwm_vn <= '0';
                pwm_wp <= '0';
                pwm_wn <= '0';
            elsif carrier_cnt >= u_ref_bb then
                pwm_up <= '1';
                pwm_un <= '0';
                pwm_vp <= '0';
                pwm_vn <= '1';
                pwm_wp <= '0';
                pwm_wn <= '1';
            else
                pwm_up <= '0';
                pwm_un <= '1';
                pwm_vp <= '1';
                pwm_vn <= '0';
                pwm_wp <= '1';
                pwm_wn <= '0';
            end if;

--            if RESET_IN = '1' then
--                pwm_vp <= '0';
--                pwm_vn <= '0';
--            elsif carrier_cnt >= v_ref_bb then
--                pwm_vp <= '0';
--                pwm_vn <= '1';
--            else
--                pwm_vp <= '1';
--                pwm_vn <= '0';
--            end if;

--            if RESET_IN = '1' then
--                pwm_wp <= '0';
--                pwm_wn <= '0';
--            elsif carrier_cnt >= w_ref_bb then
--                pwm_wp <= '0';
--                pwm_wn <= '1';
--            else
--                pwm_wp <= '1';
--                pwm_wn <= '0';
--            end if;

        end if;
    end process;
    
--    process(CLK_IN) -- 294 
--    begin
--        if CLK_IN'event and CLK_IN = '1' then
--            if RESET_IN = '1' then
--                wp_delay_line <= (others => '0');
--                wn_delay_line <= (others => '0');
--            else
--                for i in 293 downto 1 loop
--                    wp_delay_line(i) <= wp_delay_line(i-1);
--                    wn_delay_line(i) <= wn_delay_line(i-1);
--                end loop;
--                wp_delay_line(0) <= pwm_wp;
--                wn_delay_line(0) <= pwm_wn;
--            end if;
--        end if;
--    end process;

    process(CLK_IN)
    begin
        if CLK_IN'event and CLK_IN = '1' then
            if RESET_IN = '1' then
                dt_bb <= '0' & X"190"; -- 4us
            elsif carrier_cnt = (carrier_cnt_max_bb -1) then
                dt_bb <= dt_b;
            end if;
        end if;
    end process;
    
        -- ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽPDM?ｿｽ?ｿｽp?ｿｽﾌゑｿｽ?ｿｽﾂゑｿｽ?ｿｽ?ｿｽ????????
    -- up,un,vp,vn?ｿｽ?ｿｽS1,S2,S3,S4?ｿｽﾆゑｿｽ?ｿｽﾄ暦ｿｽ?ｿｽp?ｿｽ?ｿｽ?ｿｽ?ｿｽ
    pdm : pulse_generator port map (
        clk => CLK_IN,
        reset => RESET_IN,
        TPDM_in => TPDM,
        T1_in => T1,
        T2_in => T2,
        TD_in => TD,
        S1_in => pwm_up,
        S2_in => pwm_un,
        S3_in => pwm_vp,
        S4_in => pwm_vn,
        S5_in => pwm_wp,
        S6_in => pwm_wn,
        S1_out => pwm_up_dt,
        S2_out => pwm_un_dt,
        S3_out => pwm_vp_dt,
        S4_out => pwm_vn_dt,
        S5_out => pwm_wp_dt,
        S6_out => pwm_wn_dt
);

    dt_up : deadtime_if port map (CLK_IN => CLK_IN, RESET_IN => RESET_IN, DT => dt_bb, G_IN => pwm_up_dt, G_OUT => pwm_up_dt2);
    dt_un : deadtime_if port map (CLK_IN => CLK_IN, RESET_IN => RESET_IN, DT => dt_bb, G_IN => pwm_un_dt, G_OUT => pwm_un_dt2);
    dt_vp : deadtime_if port map (CLK_IN => CLK_IN, RESET_IN => RESET_IN, DT => dt_bb, G_IN => pwm_vp_dt, G_OUT => pwm_vp_dt2);
    dt_vn : deadtime_if port map (CLK_IN => CLK_IN, RESET_IN => RESET_IN, DT => dt_bb, G_IN => pwm_vn_dt, G_OUT => pwm_vn_dt2);
--    dt_wp : deadtime_if port map (CLK_IN => CLK_IN, RESET_IN => RESET_IN, DT => dt_bb, G_IN => pwm_wp_dt, G_OUT => pwm_wp_dt2);
--    dt_wn : deadtime_if port map (CLK_IN => CLK_IN, RESET_IN => RESET_IN, DT => dt_bb, G_IN => pwm_wn_dt, G_OUT => pwm_wn_dt2);




    -- ?ｿｽﾈ会ｿｽ??????????ｿｽo?ｿｽﾍ信?ｿｽ?ｿｽ?ｿｽﾉ渡?ｿｽ?ｿｽ?ｿｽﾛゑｿｽand?ｿｽﾌ托ｿｽ?????????ｿｽﾏ撰ｿｽ?ｿｽ?ｿｽ?????????pwm_up_dt?ｿｽ?ｿｽpwm_up_dt2?ｿｽﾉ変更?ｿｽB?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽl??????????ｿｽ?ｿｽ???ｿｽ?ｿｽw?ｿｽ?ｿｽ?ｿｽﾌゑｿｽ??????????ｿｽﾍ変更?ｿｽ?ｿｽ????????
    nPWM_UP_OUT <= not (pwm_up_dt2 and gate_en_b);
    nPWM_UN_OUT <= not (pwm_un_dt2 and gate_en_b);
    nPWM_VP_OUT <= not (pwm_vp_dt2 and gate_en_b);
    nPWM_VN_OUT <= not (pwm_vn_dt2 and gate_en_b);
    nPWM_WP_OUT <= not (pwm_wp_dt and gate_en_b);
    nPWM_WN_OUT <= not (pwm_wn_dt and gate_en_b);

    nUSER_OPT_OUT(6) <= not gate_en_b;
    nUSER_OPT_OUT(7) <= gate_en_b;
    nUSER_OPT_OUT(8) <= not (pwm_vp_dt2 and gate_en_b);
    nUSER_OPT_OUT(9) <= not (pwm_vn_dt2 and gate_en_b);
    nUSER_OPT_OUT(10) <= not (pwm_wp_dt and gate_en_b);
    nUSER_OPT_OUT(11) <= not (pwm_wn_dt and gate_en_b);
    nUSER_OPT_OUT(12) <= not (pwm_up_dt2 and gate_en_b);
    nUSER_OPT_OUT(13) <= not (pwm_un_dt2 and gate_en_b);
    nUSER_OPT_OUT(14) <= not (pwm_vp_dt2 and gate_en_b);
    nUSER_OPT_OUT(15) <= not (pwm_vn_dt2 and gate_en_b);
    nUSER_OPT_OUT(16) <= not (pwm_wp_dt and gate_en_b);
    nUSER_OPT_OUT(17) <= not (pwm_wn_dt and gate_en_b);
    nUSER_OPT_OUT(18) <= not (pwm_up_dt2 and gate_en_b);
    nUSER_OPT_OUT(19) <= not (pwm_un_dt2 and gate_en_b);
    nUSER_OPT_OUT(20) <= not (pwm_vp_dt2 and gate_en_b);
    nUSER_OPT_OUT(21) <= not (pwm_vn_dt2 and gate_en_b);
    nUSER_OPT_OUT(22) <= not (pwm_wp_dt and gate_en_b);
    nUSER_OPT_OUT(23) <= not (pwm_wn_dt and gate_en_b);

end Behavioral;


----------------------------------------------------------------------------------
--Deadtime module
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;

entity deadtime_if is
    Port (
        CLK_IN     : in std_logic;
        RESET_IN : in std_logic;
        DT           : in std_logic_vector(12 downto 0);
        G_IN        : in std_logic;
        G_OUT      : out std_logic
        );
end deadtime_if;

architecture behavioral of deadtime_if is
signal d_g_in: std_logic;
signal cnt: std_logic_vector(12 downto 0);
signal gate: std_logic;

begin

    process(CLK_IN)
    begin
        if (CLK_IN'event and CLK_IN='1') then
            if RESET_IN = '1' then
                d_g_in <= '0';
            else
                d_g_in <= G_IN;
            end if;

            if RESET_IN = '1' then
                cnt   <= "0000000000001";
                gate <= '0';
            elsif (d_g_in = '0' and G_IN = '1') then
                cnt   <= "0000000000001";
                gate <= '0';
            elsif (cnt >= DT) then
                cnt   <= "1111111111111";
                gate <= d_g_in;
            elsif (cnt /= "1111111111111") then
                cnt   <= cnt + 1;
                gate <= '0';
            else
                gate <= d_g_in;
            end if;
        end if;
    end process;

    G_OUT <= gate;

end behavioral;


----------------------------------------------------------------------------------
--PDM module
-- 1. pulse_generator?ｿｽﾌ?ｿｽ?ｿｽW?ｿｽ?ｿｽ?ｿｽ[?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ????????(?????????ｿｽﾔ会ｿｽ?????????deadtime_if?ｿｽﾌ会ｿｽ??

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity pulse_generator is
    Port (
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        TPDM_in       : in  std_logic_vector(31 downto 0); -- PDM?ｿｽ?ｿｽ????????
        T1_in         : in  std_logic_vector(31 downto 0); -- ?????????ｿｽd?ｿｽp?ｿｽ?ｿｽ?ｿｽX?ｿｽ?ｿｽ?ｿｽ?ｿｽ
        T2_in         : in  std_logic_vector(31 downto 0); -- ?ｿｽ?ｿｽd?ｿｽp?ｿｽ?ｿｽ?ｿｽX?ｿｽ?ｿｽ?ｿｽ?ｿｽ
        TD_in         : in  std_logic_vector(31 downto 0); -- ?????????ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ
        S1_in         : in  STD_LOGIC;
        S2_in         : in  STD_LOGIC;
        S3_in         : in  STD_LOGIC;
        S4_in         : in  STD_LOGIC;
        S5_in         : in  STD_LOGIC;
        S6_in         : in  STD_LOGIC;
        S1_out        : out STD_LOGIC;
        S2_out        : out STD_LOGIC;
        S3_out        : out STD_LOGIC;
        S4_out        : out STD_LOGIC;
        S5_out        : out STD_LOGIC;
        S6_out        : out STD_LOGIC
    );
end pulse_generator;

--output_signal?ｿｽﾌ出?ｿｽﾍゑｿｽ1?ｿｽﾌ場合??????????ｿｽX?ｿｽC?????????ｿｽ`?ｿｽM?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽﾌまま出?ｿｽﾍゑｿｽ?ｿｽ?ｿｽ???
--output_signal?ｿｽﾌ出?ｿｽﾍゑｿｽ0?ｿｽﾌ場合??????????ｿｽV?ｿｽ?ｿｽ?ｿｽ[?ｿｽg?ｿｽ?ｿｽ?ｿｽ[?ｿｽh?ｿｽ?ｿｽ?ｿｽo?ｿｽﾍゑｿｽ?ｿｽ?ｿｽ???

architecture Behavioral of pulse_generator is
    signal cnt_inv : integer := 0; -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^
    signal cnt_rect : integer := 0; -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^
    signal cnt_max_inv : integer := 10000; -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽ?ｿｽ?????????ｿｽ?ｿｽl
    signal cnt_max_rect : integer := 10000; -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽ?ｿｽ?????????ｿｽ?ｿｽl
    signal output_signal_inv : STD_LOGIC := '0';
    signal output_signal_rect : STD_LOGIC := '0';
    signal tpdm_int, t1_int, t2_int, td_int : integer; -- TPDM, T1, T2, TD?ｿｽｮ撰ｿｽ?ｿｽ^?ｿｽﾉ変奇ｿｽ
    signal pwm_up_d : std_logic := '0';    -- pwm_up??1?ｿｽN?ｿｽ?ｿｽ???ｿｽN???ｿｽB?ｿｽ?ｿｽ?ｿｽC?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ????ｿｽ?ｿｽﾛ趣ｿｽ
    signal pwm_wp_d : std_logic := '0';
    -- signal pwm_up_dd : std_logic := '0';    -- pwm_up??1?ｿｽN?ｿｽ?ｿｽ???ｿｽN???ｿｽB?ｿｽ?ｿｽ?ｿｽC?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ????ｿｽ?ｿｽﾛ趣ｿｽ
    signal pwm_counter : integer := 0;     -- pwm_up?ｿｽﾌ回数カ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^
    signal rect_counter : integer := 0;
    signal rect_delay : std_logic_vector(293 downto 0);
    signal ac_voltage : integer := 0 ;

    -- mark_debug ?ｿｽﾌ撰ｿｽ????????
    attribute mark_debug : string;

    -- ?????????ｿｽM?ｿｽ?ｿｽ?ｿｽ?ｿｽ mark_debug ?ｿｽ?ｿｽt??
    attribute mark_debug of output_signal_inv : signal is "true";
    attribute mark_debug of output_signal_rect : signal is "true";
    attribute mark_debug of pwm_up_d : signal is "true";
    attribute mark_debug of pwm_wp_d : signal is "true";
    -- attribute mark_debug of pwm_up_dd : signal is "ture";
    attribute mark_debug of pwm_counter : signal is "true";
    attribute mark_debug of rect_counter : signal is "true";
    attribute mark_debug of ac_voltage : signal is "true";
begin
    -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽﾆ出?ｿｽﾍ信?ｿｽ?ｿｽ?ｿｽﾌ撰ｿｽ?ｿｽ?ｿｽv?ｿｽ?ｿｽ?ｿｽZ?ｿｽX????????????????ｿｽC?ｿｽ?ｿｽ?ｿｽo??????????ｿｽ^?ｿｽ?ｿｽ?????????
    process(clk, reset)
    begin
        if reset = '1' then
            pwm_up_d <= '0';
            -- pwm_up_dd <= '0';
            pwm_counter <= 0;
            output_signal_inv <= '0';
            cnt_max_inv <= 20;
        elsif (clk'event and clk='1') then -- count half period of pwm_up
            cnt_max_inv <= tpdm_int;
            pwm_up_d <= S1_in;
            if (S1_in ='1' and pwm_up_d ='0') then
                pwm_counter <= pwm_counter + 1;
            elsif (S1_in ='0' and pwm_up_d ='1') then
                pwm_counter <= pwm_counter + 1;
            end if;
            
            if pwm_counter >= cnt_max_inv - 1 then
                pwm_counter <= 0; -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽZ????????????????
            end if;

            if pwm_counter < t1_int then
                output_signal_inv <= '0';
            else
                output_signal_inv <= '1';
            end if;
        end if;
    end process;
    
    process(clk,reset)
    begin
        if output_signal_inv = '0' then
            ac_voltage <= 1;
        elsif output_signal_inv = '1' and S1_in = '1' and S2_in = '0' and S3_in = '0' and S4_in = '1' then
            ac_voltage <= 2;
        elsif output_signal_inv = '1' and S1_in = '0' and S2_in = '1' and S3_in = '1' and S4_in = '0' then
            ac_voltage <= 0;
        else
            ac_voltage <= 5;
        end if;
    end process;

    -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽﾆ出?ｿｽﾍ信?ｿｽ?ｿｽ?ｿｽﾌ撰ｿｽ?ｿｽ?ｿｽv?ｿｽ?ｿｽ?ｿｽZ?ｿｽX?????????rect?ｿｽ?ｿｽ?????????
    process(clk, reset)
    begin
        if reset = '1' then
            pwm_wp_d <= '0';
            -- cnt_rect <= 0;
            rect_counter <= 0;
            cnt_max_rect <= 60; -- ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽl
            output_signal_rect <= '0';
        elsif (clk'event and clk='1') then
            -- ?????????ｿｽ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽg??????????ｿｽ?ｿｽTPDM?ｿｽﾉ奇ｿｽ?ｿｽ?????????ｿｽﾄ更?ｿｽV
            cnt_max_rect <= tpdm_int;
            pwm_wp_d <= S5_in;
            if (S5_in ='1' and pwm_wp_d = '0') then
                rect_counter <= rect_counter + 1;
            elsif (S5_in ='0' and pwm_wp_d = '1') then
                rect_counter <= rect_counter + 1;
            end if;
            
            if rect_counter >= cnt_max_rect - 1 then
                rect_counter <= 0;
            end if;
            
            if rect_counter < td_int then
                output_signal_rect <= '1';
            elsif rect_counter < t2_int + td_int then
                output_signal_rect <= '0';
            else 
                output_signal_rect <= '1';
            end if;
            
            
--            -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽﾌ難ｿｽ??
--            if cnt_rect >= cnt_max_rect then
--                cnt_rect <= 0; -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽZ????????????????
--            else
--                cnt_rect <= cnt_rect + 1; -- ?ｿｽJ?ｿｽE?ｿｽ?ｿｽ?ｿｽ^?ｿｽ?ｿｽ?ｿｽC?ｿｽ?ｿｽ?ｿｽN?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ????????
--            end if;

            -- ?ｿｽo?ｿｽﾍ信?ｿｽ?ｿｽ?ｿｽﾌ撰ｿｽ?ｿｽ?ｿｽ?????????294?ｿｽN?ｿｽ?ｿｽ?????????ｿｽN?????????ｿｽ?ｿｽ?ｿｽ?ｿｽ?ｿｽ?????????????????
--            if cnt_rect < (td_int + 294) then
--                output_signal_rect <= '1'; -- (td_int + 294) ?ｿｽﾌ奇ｿｽ????????? '1'
--            elsif cnt_rect < (td_int + t2_int + 294) then
--                output_signal_rect <= '0'; -- (td_int + 294) ?ｿｽ?ｿｽ?ｿｽ?ｿｽ (td_int + t2_int + 294) ?ｿｽﾌ奇ｿｽ????????? '0'
--            else
--                output_signal_rect <= '1'; -- ?ｿｽ?ｿｽ?ｿｽ?ｿｽﾈ降????????? '1'
--            end if;
        end if;
    end process;

    -- TPDM, T1, T2, TD?ｿｽﾌ変奇ｿｽ?ｿｽv?ｿｽ?ｿｽ?ｿｽZ?ｿｽX
    process(TPDM_in, T1_in, T2_in, TD_in)
        variable tpdm_var : integer;
        variable t1_var : integer;
        variable t2_var : integer;
        variable td_var : integer;
    begin
        tpdm_var := to_integer(unsigned(TPDM_in)); -- std_logic_vector?ｿｽｮ撰ｿｽ?ｿｽﾉ変奇ｿｽ
        t1_var   := to_integer(unsigned(T1_in));
        t2_var   := to_integer(unsigned(T2_in));
        td_var   := to_integer(unsigned(TD_in));
        
        tpdm_int <= tpdm_var;
        t1_int <= t1_var;
        t2_int <= t2_var;
        td_int <= td_var;
    end process;

    -- ?ｿｽX?ｿｽC?????????ｿｽ`?ｿｽM?ｿｽ?ｿｽ?ｿｽﾌ撰ｿｽ?ｿｽ?ｿｽv?ｿｽ?ｿｽ?ｿｽZ?ｿｽX????????????????ｿｽC?ｿｽ?ｿｽ?ｿｽo??????????ｿｽ^?ｿｽ?ｿｽ?????????
    process(S1_in, S2_in, S3_in, S4_in)
    begin
        if output_signal_inv = '1' then
            S1_out <= S1_in;
            S2_out <= S2_in;
            S3_out <= S3_in;
            S4_out <= S4_in;
        else
            S1_out <= '0';
            S2_out <= '1';
            S3_out <= '0';
            S4_out <= '1';
        end if;
    end process;
    
    process(clk,reset) -- 294 
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                rect_delay <= (others => '0');
            else
                for i in 293 downto 1 loop
                    rect_delay(i) <= rect_delay(i-1);
                end loop;
                rect_delay(0) <= output_signal_rect;
            end if;
        end if;
    end process;

    -- ?ｿｽX?ｿｽC?????????ｿｽ`?ｿｽM?ｿｽ?ｿｽ?ｿｽﾌ撰ｿｽ?ｿｽ?ｿｽv?ｿｽ?ｿｽ?ｿｽZ?ｿｽX?????????rect?ｿｽ?ｿｽ?????????
    process(clk)
    begin
        if rect_delay(293) = '1' then
            S5_out <= '0';
            S6_out <= '0';
        else
            S5_out <= '1';
            S6_out <= '1';
        end if;
    end process;

end Behavioral;