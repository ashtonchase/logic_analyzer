
ARCHITECTURE behavioral OF capture_ctrl IS


  --entity related signals
  SIGNAL din_ff           : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL armed_o          : STD_LOGIC                               := '0';
  SIGNAL triggered_o      : STD_LOGIC                               := '0';
  SIGNAL sample_cnt_rst_o : STD_LOGIC                               := '1';
  SIGNAL delay_cnt_4x_l   : STD_LOGIC_VECTOR(16-1 DOWNTO 0)         := (OTHERS => '0');
  SIGNAL read_cnt_4x_l    : STD_LOGIC_VECTOR(16-1 DOWNTO 0)         := (OTHERS => '1');
  SIGNAL par_trig_msk_l   : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL par_trig_val_l   : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL capture_rdy_o    : STD_LOGIC                               := '0';
  SIGNAL fifo_tdata_o     : STD_LOGIC_VECTOR(32-1 DOWNTO 0)         := (OTHERS => '1');
  SIGNAL fifo_tvalid_o    : STD_LOGIC                               := '0';
  SIGNAL fifo_tlast_o     : STD_LOGIC                               := '0';

  SIGNAL trig : STD_LOGIC :='0';

  --state machine signals
  TYPE state_t IS (INIT, WAIT_FOR_ARM_CMD, WAIT_FOR_TRIGGER, DELAY_HOLD, CAPTURE_DATA);
  SIGNAL state : state_t := INIT;

  --capture count
  SIGNAL capture_cnt,capture_cnt_plus, delay_cnt, delay_cnt_plus : NATURAL RANGE 0 TO 262_141+1 := 0;
 

BEGIN  -- ARCHITECTURE behavioral

  --fast trigger detect
  trig <='1' when ((din_ff AND par_trig_val_l) = par_trig_msk_l) else
         '0';
  --fast adds
  capture_cnt_plus<=capture_cnt + 1; 
  delay_cnt_plus<=delay_cnt+1;
  -----------------------------------------------------------------------------
  -- Concurrent assigments
  -----------------------------------------------------------------------------
  --fifo assignments
  fifo_tdata  <= fifo_tdata_o;
  fifo_tvalid <= fifo_tvalid_o;
  fifo_tlast  <= fifo_tlast_o;
  --mp_assignemets
  capture_rdy <= capture_rdy_o;
  --top lelel assigments
  armed       <= armed_o;
  triggered   <= triggered_o;
  sample_cnt_rst <= sample_cnt_rst_o;

  -----------------------------------------------------------------------------
  -- Processes
  -----------------------------------------------------------------------------
  -- purpose: this is the main capture process encapsulating a state machine
  -- type   : sequential
  -- inputs : clk, rst
  -- outputs: 
  capture_process : PROCESS (clk) IS
    PROCEDURE inc (
      SIGNAL val_to_inc : INOUT NATURAL) IS
    BEGIN
      val_to_inc <= val_to_inc+1;
    END PROCEDURE;

  BEGIN  -- PROCESS capture_process
    is_clk : IF rising_edge(clk) THEN   -- rising clock edge
      --default assigments
      din_ff                              <= din;
      fifo_tdata_o                        <= (OTHERS => '-');
      fifo_tdata_o(DATA_WIDTH-1 DOWNTO 0) <= din_ff;
      fifo_tvalid_o                       <= '0';
      fifo_tlast_o                        <= '0';
      sample_cnt_rst_o                    <= '1';
      capture_rdy_o                       <= '0';
      fifo_aresetn                        <= '0';

      is_rst : IF rst = '1' THEN        -- synchronous reset (active high)
        state <= INIT;
        fifo_aresetn                        <= '1';
      ELSE
        fsm : CASE state IS
          WHEN INIT =>
            is_fifo_ready : IF fifo_tready = '1' THEN
              state       <= WAIT_FOR_ARM_CMD;
              capture_cnt <= 0;
              delay_cnt   <= 0;
              armed_o     <= '0';
              triggered_o <= '0';
            END IF is_fifo_ready;
          -------------------------------------------------------------------
          WHEN WAIT_FOR_ARM_CMD =>
            par_trig_msk_l <= par_trig_msk(DATA_WIDTH-1 DOWNTO 0);
            par_trig_val_l <= par_trig_val(DATA_WIDTH-1 DOWNTO 0);
            delay_cnt_4x_l <= delay_cnt_4x;
            read_cnt_4x_l  <= delay_cnt_4x;
            capture_rdy_o  <= '1';
            is_arm : IF arm_cmd = '1' THEN
              state   <= WAIT_FOR_TRIGGER;
              armed_o <= '1';
            END IF is_arm;
          -------------------------------------------------------------------
          WHEN WAIT_FOR_TRIGGER =>

            is_trigged : IF trig='1' THEN
              --go delay if requred
              should_delay : IF delay_cnt_4x_l = X"00_00" THEN
                state            <= CAPTURE_DATA;
                sample_cnt_rst_o <= '0';
                fifo_tvalid_o    <= '1';
              ELSE
                state <= DELAY_HOLD;
              END IF should_delay;
              triggered_o <= '1';
              capture_cnt<=capture_cnt_plus;
            END IF is_trigged;
          -------------------------------------------------------------------
          WHEN DELAY_HOLD =>
            is_dly_done : IF (delay_cnt = to_integer(UNSIGNED(delay_cnt_4x_l))*8) THEN
              delay_cnt <= 0;
              state     <= CAPTURE_DATA;
            ELSIF sample_enable = '1' THEN
             delay_cnt<=delay_cnt_plus;
            END IF is_dly_done;
          -------------------------------------------------------------------
          WHEN CAPTURE_DATA =>
            --keep sample rate clock from being reset
            sample_cnt_rst_o <= '0';
            triggered_o      <= '1';

            --will the next sample be the last one, the go ahead an assert tlast.
            is_ready_for_tlast : IF (capture_cnt+1 = to_integer(UNSIGNED(read_cnt_4x_l))*8) THEN
              fifo_tlast_o <= '1';
            END IF is_ready_for_tlast;

            is_done : IF (capture_cnt = to_integer(UNSIGNED(read_cnt_4x_l))*8) THEN
              state     <= INIT;
              delay_cnt <= 0;
            --else more samples to collect
            ELSIF delay_cnt_4x_l = X"00_00" THEN
            capture_cnt<=capture_cnt_plus;
              fifo_tvalid_o <= '1';
            ELSIF sample_enable = '1' THEN
            capture_cnt<=capture_cnt_plus;
              fifo_tvalid_o <= '1';

            END IF is_done;
          -------------------------------------------------------------------
          WHEN OTHERS => NULL;
        END CASE fsm;

      END IF is_rst;
    END IF is_clk;
  END PROCESS capture_process;



-----------------------------------------------------------------------------
-- Component Instantiations
-----------------------------------------------------------------------------


END ARCHITECTURE behavioral;
