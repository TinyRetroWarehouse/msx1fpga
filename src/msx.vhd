-------------------------------------------------------------------------------
--
-- Copyright (c) 2016, Fabio Belavenuto (belavenuto@gmail.com)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity msx is
	generic (
		hw_id_g			: integer								:= 0;
		hw_txt_g			: string 								:= "NONE";
		hw_version_g	: std_logic_vector(7 downto 0)	:= X"00";
		is_pal_g			: boolean								:= false
	);
	port (
		-- Clocks
		clock_i			: in  std_logic;
		clock_vdp_i		: in  std_logic;
		clock_cpu_i		: in  std_logic;
		clock_psg_en_i	: in  std_logic;
		-- Turbo
		turbo_on_k_i	: in  std_logic;
		turbo_on_o		: out std_logic;
		-- Resets
		reset_i			: in  std_logic;
		por_i				: in  std_logic;
		softreset_o		: out std_logic;
		-- Options
		opt_nextor_i	: in  std_logic;
		opt_mr_type_i	: in  std_logic_vector(1 downto 0);
		-- RAM
		ram_addr_o		: out std_logic_vector(18 downto 0);	-- 512K
		ram_data_i		: in  std_logic_vector( 7 downto 0);
		ram_data_o		: out std_logic_vector( 7 downto 0);
		ram_ce_o			: out std_logic;
		ram_oe_o			: out std_logic;
		ram_we_o			: out std_logic;
		-- ROM
		rom_addr_o		: out std_logic_vector(14 downto 0);	-- 32K
		rom_data_i		: in  std_logic_vector( 7 downto 0);
		rom_ce_o			: out std_logic;
		rom_oe_o			: out std_logic;
		-- External bus
		bus_addr_o		: out std_logic_vector(15 downto 0);
		bus_data_i		: in  std_logic_vector( 7 downto 0);
		bus_data_o		: out std_logic_vector( 7 downto 0);
		bus_rd_n_o		: out std_logic;
		bus_wr_n_o		: out std_logic;
		bus_m1_n_o		: out std_logic;
		bus_iorq_n_o	: out std_logic;
		bus_mreq_n_o	: out std_logic;
		bus_sltsl1_n_o	: out std_logic;
		bus_sltsl2_n_o	: out std_logic;
		bus_wait_n_i	: in  std_logic;
		bus_nmi_n_i		: in  std_logic;
		bus_int_n_i		: in  std_logic;
		-- VDP VRAM
		vram_addr_o		: out std_logic_vector(13 downto 0);	-- 16K
		vram_data_i		: in  std_logic_vector( 7 downto 0);
		vram_data_o		: out std_logic_vector( 7 downto 0);
		vram_ce_o		: out std_logic;
		vram_oe_o		: out std_logic;
		vram_we_o		: out std_logic;
		-- Keyboard
		rows_o			: out std_logic_vector(3 downto 0);
		cols_i			: in  std_logic_vector(7 downto 0)		:= (others => '1');
		caps_en_o		: out std_logic;
		-- Audio
		audio_scc_o		: out signed(14 downto 0);
		audio_psg_o		: out unsigned(7 downto 0);
		beep_o			: out std_logic;
		-- K7
		k7_motor_o		: out std_logic;
		k7_audio_o		: out std_logic;
		k7_audio_i		: in  std_logic;
		-- Joystick
		joy1_up_i		: in    std_logic;
		joy1_down_i		: in    std_logic;
		joy1_left_i		: in    std_logic;
		joy1_right_i	: in    std_logic;
		joy1_btn1_io	: inout std_logic;
		joy1_btn2_io	: inout std_logic;
		joy1_out_o		: out   std_logic;
		joy2_up_i		: in    std_logic;
		joy2_down_i		: in    std_logic;
		joy2_left_i		: in    std_logic;
		joy2_right_i	: in    std_logic;
		joy2_btn1_io	: inout std_logic;
		joy2_btn2_io	: inout std_logic;
		joy2_out_o		: out   std_logic;
		-- Video
		col_o				: out std_logic_vector( 3 downto 0);
		rgb_r_o			: out std_logic_vector( 3 downto 0);
		rgb_g_o			: out std_logic_vector( 3 downto 0);
		rgb_b_o			: out std_logic_vector( 3 downto 0);
		hsync_n_o		: out std_logic;
		vsync_n_o		: out std_logic;
		csync_n_o		: out std_logic;
		-- SPI/SD
		spi_cs_n_o		: out std_logic;
		spi_sclk_o		: out std_logic;
		spi_mosi_o		: out std_logic;
		spi_miso_i		: in  std_logic								:= '0';
		-- DEBUG
		D_wait_o			: out std_logic;
		D_slots_o		: out std_logic_vector( 7 downto 0)
	);

end entity;

architecture Behavior of msx is

	-- Turbo
	signal turbo_on_s			: std_logic;

	-- Reset
	signal reset_n_s			: std_logic;
	signal por_n_s				: std_logic;
	signal softreset_s		: std_logic;

	-- CPU signals
	signal int_n_s				: std_logic;
	signal iorq_n_s			: std_logic;
	signal m1_n_s           : std_logic;
	signal wait_n_s			: std_logic;
	signal rd_n_s				: std_logic;
	signal wr_n_s				: std_logic;
	signal mreq_n_s			: std_logic;
	signal rfsh_n_s			: std_logic;
	signal cpu_addr_s			: std_logic_vector(15 downto 0);
	signal d_to_cpu_s			: std_logic_vector( 7 downto 0);
	signal d_from_cpu_s		: std_logic_vector( 7 downto 0);

	-- Bus and Wait
	signal m1_wait_n_s		: std_logic;
	signal m1_wait_qn_s		: std_logic;
	signal vdp_int_n_s		: std_logic;
	signal nrd_s				: std_logic;
	signal nwr_s				: std_logic;
	signal niorq_s				: std_logic;
	signal vdp_wait_s			: std_logic;

	-- Address Decoder
	signal io_access_s		: std_logic;
	signal io_read_s			: std_logic;
	signal io_write_s			: std_logic;

	-- Memory
	signal prim_slot_n_s		: std_logic_vector( 3 downto 0)		:= "1111";
	signal pslot_s				: std_logic_vector( 1 downto 0)		:= "00";
	signal d_from_exp_s		: std_logic_vector( 7 downto 0);
	signal slot3_exp_n_s		: std_logic_vector( 3 downto 0)		:= "1111";
	signal exp_has_data_s	: std_logic;
	signal brom_cs_s			: std_logic;
	signal ram_cs_s			: std_logic;
	signal ram_page_s			: std_logic_vector( 4 downto 0);
	signal use_rom_in_ram_s	: std_logic;

	-- IPL
	signal ipl_en_s			: std_logic;
	signal iplrom_addr_s		: std_logic_vector(12 downto 0);
	signal d_from_iplrom_s	: std_logic_vector( 7 downto 0);
	signal iplrom_cs_s		: std_logic;
	signal iplram_cs_s		: std_logic;
	signal iplram_bw_s		: std_logic;

	-- Mapper
	signal mp_page_s			: std_logic_vector( 2 downto 0);
	signal mp_bank0_s			: std_logic_vector( 2 downto 0);
	signal mp_bank1_s			: std_logic_vector( 2 downto 0);
	signal mp_bank2_s			: std_logic_vector( 2 downto 0);
	signal mp_bank3_s			: std_logic_vector( 2 downto 0);
	signal mp_cs_s				: std_logic;
	signal d_from_mp_s		: std_logic_vector( 7 downto 0);

	-- VDP18
	signal d_from_vdp_s     : std_logic_vector( 7 downto 0);
	signal vdp_rd_n_s			: std_logic;
	signal vdp_wr_n_s			: std_logic;

	-- PSG
	signal psg_cs_s			: std_logic;
	signal psg_bdir_s			: std_logic;
	signal psg_bc1_s			: std_logic;
	signal d_from_psg_s		: std_logic_vector( 7 downto 0);
	signal psg_port_a_s		: std_logic_vector( 7 downto 0)	:= (others => '1');
	signal psg_port_b_s		: std_logic_vector( 7 downto 0);

	-- Joystick
	alias  joy_sel_a			: std_logic is psg_port_b_s(6);
	signal joy_sigs_s			: std_logic_vector(5 downto 0);

	-- PIO
	signal d_from_pio_s		: std_logic_vector( 7 downto 0);
	signal pio_hd_s			: std_logic;
	signal pio_cs_s			: std_logic;
	signal pio_rd_s			: std_logic;
	signal pio_wr_s			: std_logic;
	signal pio_port_a_s		: std_logic_vector( 7 downto 0);
	signal pio_port_c_s		: std_logic_vector( 7 downto 0);

	alias  pio_rows_coded_a	: std_logic_vector( 3 downto 0) is pio_port_c_s(3 downto 0);
	alias  pio_motoron_a		: std_logic is pio_port_c_s(4);
	alias  pio_k7out_a		: std_logic is pio_port_c_s(5);
	alias  pio_caps_a			: std_logic is pio_port_c_s(6);
	alias  pio_beep_a			: std_logic is pio_port_c_s(7);

	-- Switched I/O ports
	signal swp_hd_s			: std_logic;
	signal d_from_swp_s		: std_logic_vector( 7 downto 0);

	-- SPI/SD
	signal nextor_en_s		: std_logic;
	signal spi_cs_s			: std_logic;
	signal spi_hd_s			: std_logic;
	signal d_from_spi_s		: std_logic_vector( 7 downto 0);
	signal nxt_rom_page_s	: std_logic_vector( 2 downto 0);
	signal nxt_rom_cs_s		: std_logic;

	-- SCC/Megaram
	signal mram_cs_s			: std_logic;
	signal d_from_mram_s		: std_logic_vector( 7 downto 0);
	signal mr_type_s			: std_logic_vector( 1 downto 0);
	signal mr_ram_addr_s		: std_logic_vector(18 downto 0);
	signal mr_ram_ce_s		: std_logic;
	signal mr_audio_s			: signed(14 downto 0);
	signal mr_audio_std_s	: std_logic_vector(14 downto 0);

begin

	-- CPU
	cpu: entity work.T80a
	generic map (
		mode_g		=> 0
	)
	port map (
		clock_i		=> clock_cpu_i,
		clock_en_i	=> '1',
		reset_n_i	=> reset_n_s,
		address_o	=> cpu_addr_s,
		data_i		=> d_to_cpu_s,
		data_o		=> d_from_cpu_s,
		wait_n_i		=> wait_n_s,
		int_n_i		=> int_n_s,
		nmi_n_i		=> bus_nmi_n_i,
		m1_n_o		=> m1_n_s,
		mreq_n_o		=> mreq_n_s,
		iorq_n_o		=> iorq_n_s,
		rd_n_o		=> rd_n_s,
		wr_n_o		=> wr_n_s,
		refresh_n_o	=> rfsh_n_s,
		halt_n_o		=> open,
		busrq_n_i	=> '1',
		busak_n_o	=> open
	);

	-- IPL ROM
	ipl: entity work.ipl_rom
	port map (
		clk		=> clock_i,
		addr		=> iplrom_addr_s,
		data		=> d_from_iplrom_s
	);

	-- VDP
	vdp: entity work.vdp18_core
	generic map (
		is_pal_g			=> is_pal_g,
		is_cvbs_g		=> (hw_id_g = 8)
	)
	port map (
		clock_i			=> clock_i,
		clk_en_10m7_i	=> clock_vdp_i,
		reset_n_i		=> reset_n_s,
		csr_n_i			=> vdp_rd_n_s,
		csw_n_i			=> vdp_wr_n_s,
		mode_i			=> cpu_addr_s(1 downto 0),
		int_n_o			=> vdp_int_n_s,
		cd_i				=> d_from_cpu_s,
		cd_o				=> d_from_vdp_s,
		wait_o			=> vdp_wait_s,
		vram_ce_o		=> vram_ce_o,
		vram_oe_o		=> vram_oe_o,
		vram_we_o		=> vram_we_o,
		vram_a_o			=> vram_addr_o,
		vram_d_o			=> vram_data_o,
		vram_d_i			=> vram_data_i,
		col_o				=> col_o,
		rgb_r_o			=> rgb_r_o,
		rgb_g_o			=> rgb_g_o,
		rgb_b_o			=> rgb_b_o,
		hsync_n_o		=> hsync_n_o,
		vsync_n_o		=> vsync_n_o,
		comp_sync_n_o	=> csync_n_o
	);

	-- PSG
	psg: entity work.YM2149
	port map (
		clock_i				=> clock_i,
		clock_en_i			=> clock_psg_en_i,	-- clock enable 3.57 MHz
		reset_i				=> reset_i,
		sel_n_i				=> '0',					-- no division (clock = 3.57)
		ayymmode_i			=> '0',
		-- data bus
		data_i				=> d_from_cpu_s,
		data_o				=> d_from_psg_s,
		-- control
		a9_l_i				=> '0',
		a8_i					=> '1',
		bdir_i				=> psg_bdir_s,
		bc1_i					=> psg_bc1_s,
		bc2_i					=> '1',
		-- I/O ports
		port_a_i				=> psg_port_a_s,
		port_a_o				=> open,
		port_b_i				=> (others => '0'),
		port_b_o				=> psg_port_b_s,
		-- audio channels out
		audio_ch_a_o		=> open,
		audio_ch_b_o		=> open,
		audio_ch_c_o		=> open,
		audio_ch_mix_o		=> audio_psg_o
	);

	-- PIO (82C55)
	pio: entity work.PIO
	port map (
		reset_i			=> reset_i,
		ipl_en_i			=> ipl_en_s,
		addr_i			=> cpu_addr_s(1 downto 0),
		data_i			=> d_from_cpu_s,
		data_o			=> d_from_pio_s,
		has_data_o		=> pio_hd_s,
		cs_i				=> pio_cs_s,
		rd_i				=> pio_rd_s,
		wr_i				=> pio_wr_s,
		port_a_o			=> pio_port_a_s,
		port_b_i			=> cols_i,
		port_c_o			=> pio_port_c_s
	);

	-- Slot expander
	exp: entity work.exp_slot
	port map (
		reset_i			=> reset_i,
		ipl_en_i			=> ipl_en_s,
		addr_i			=> cpu_addr_s,
		data_i			=> d_from_cpu_s,
		data_o			=> d_from_exp_s,
		has_data_o		=> exp_has_data_s,
		sltsl_n_i		=> prim_slot_n_s(3),
		rd_n_i			=> rd_n_s,
		wr_n_i			=> wr_n_s,
		expsltsl_n_o	=> slot3_exp_n_s
	);

	-- Switched I/O ports
	swiop: entity work.swioports
	port map (
		reset_i			=> reset_i,
		clock_i			=> clock_cpu_i,
		addr_i			=> cpu_addr_s(7 downto 0),
		cs_i				=> niorq_s,
		rd_i				=> nrd_s,
		wr_i				=> nwr_s,
		data_i			=> d_from_cpu_s,
		data_o			=> d_from_swp_s,
		has_data_o		=> swp_hd_s,
		--
		hw_id_i			=> std_logic_vector(to_unsigned(hw_id_g, 8)),
		hw_txt_i			=> hw_txt_g,
		hw_version_i	=> hw_version_g,
		nextor_en_i 	=> opt_nextor_i,
		mr_type_i		=> opt_mr_type_i,
		turbo_on_k_i	=> turbo_on_k_i,
		--
		nextor_en_o		=> nextor_en_s,
		mr_type_o		=> mr_type_s,
		turbo_on_o		=> turbo_on_s,
		softreset_o		=> softreset_s
	);

	-- SPI
	sd: entity work.spi
	port map (
		clock_i			=> clock_cpu_i,
		reset_i			=> reset_i,
		addr_i			=> cpu_addr_s(0),
		cs_i				=> spi_cs_s,
		wr_i				=> nwr_s,
		rd_i				=> nrd_s,
		data_i			=> d_from_cpu_s,
		data_o			=> d_from_spi_s,
		has_data_o		=> spi_hd_s,
		-- SD card interface
		spi_cs_n_o		=> spi_cs_n_o,
		spi_sclk_o		=> spi_sclk_o,
		spi_mosi_o		=> spi_mosi_o,
		spi_miso_i		=> spi_miso_i
	);

	-- ROM Nextor control
	nxt: entity work.romnextor
	port map (
		reset_i		=> reset_i,
		clock_i		=> clock_cpu_i,
		enable_i		=> nextor_en_s,
		addr_i		=> cpu_addr_s,
		data_i		=> d_from_cpu_s,
		sltsl_n_i	=> slot3_exp_n_s(2),
		rd_n_i		=> rd_n_s,
		wr_n_i		=> wr_n_s,
		--
		rom_cs_o		=> nxt_rom_cs_s,
		rom_page_o	=> nxt_rom_page_s
	);

	-- ESCCI
	escci: entity work.escci
	port map (
		clock_i		=> clock_i,
		clock_en_i	=> clock_psg_en_i,
		reset_i		=> reset_i,
		--
		addr_i		=> cpu_addr_s,
		data_i		=> d_from_cpu_s,
		data_o		=> d_from_mram_s,
		cs_i			=> mram_cs_s,
		rd_i			=> nrd_s,
		wr_i			=> nwr_s,
		--
		ram_addr_o	=> mr_ram_addr_s,
		ram_data_i	=> ram_data_i,
		ram_ce_o		=> mr_ram_ce_s,
		ram_oe_o		=> open,
		ram_we_o		=> open,
		--
		map_type_i	=> mr_type_s,					-- "-0" : SCC+, "01" : ASC8K, "11" : ASC16K
		-- Audio Out
		wave_o		=> audio_scc_o
	);

	-- Glue
	softreset_o		<= softreset_s;
	por_n_s			<= not por_i;
	reset_n_s		<= not reset_i;
	nrd_s				<= not rd_n_s;
	nwr_s				<= not wr_n_s;
	niorq_s			<= not iorq_n_s;
	ipl_en_s			<= not iplram_bw_s;

	beep_o			<= pio_beep_a;
	rows_o			<= pio_rows_coded_a;
	caps_en_o		<= not pio_caps_a;
	turbo_on_o		<= turbo_on_s;

	-- K7 and Joystick
	k7_motor_o		<= pio_motoron_a;
	k7_audio_o		<= pio_k7out_a;
	psg_port_a_s	<= k7_audio_i & '1' & joy_sigs_s;
	joy_sigs_s		<= joy1_btn2_io & joy1_btn1_io & joy1_right_i & joy1_left_i & joy1_down_i & joy1_up_i	when joy_sel_a = '0' else
							joy2_btn2_io & joy2_btn1_io & joy2_right_i & joy2_left_i & joy2_down_i & joy2_up_i;
	joy1_btn1_io	<= '0' when psg_port_b_s(0) = '0'	else 'Z';
	joy1_btn2_io	<= '0' when psg_port_b_s(1) = '0'	else 'Z';
	joy2_btn1_io	<= '0' when psg_port_b_s(2) = '0'	else 'Z';
	joy2_btn2_io	<= '0' when psg_port_b_s(3) = '0'	else 'Z';
	joy1_out_o	 	<= psg_port_b_s(4);
	joy2_out_o	 	<= psg_port_b_s(5);

	-- M1 Wait-state
	process (reset_i, clock_cpu_i)
	begin
		if reset_i = '1' then
			m1_wait_n_s		<= '1';
			m1_wait_qn_s	<= '0';
		elsif rising_edge(clock_cpu_i) then
			if turbo_on_s = '0' then
				m1_wait_n_s		<= m1_n_s or m1_wait_qn_s;
				m1_wait_qn_s	<= not (m1_n_s or m1_wait_qn_s);
			else
				m1_wait_n_s		<= '1';
			end if;
		end if;
	end process;

	-- Address decoding
	io_access_s		<= '1'	when iorq_n_s = '0' and m1_n_s = '1'							else '0';
	io_read_s		<= '1'	when iorq_n_s = '0' and m1_n_s = '1' and rd_n_s = '0'		else '0';
	io_write_s		<= '1'	when iorq_n_s = '0' and m1_n_s = '1' and wr_n_s = '0'		else '0';

	-- I/O
	vdp_wr_n_s		<= '0'	when io_write_s = '1'  and cpu_addr_s(7 downto 2) = "100110"	else '1';	-- VDP write	=> 98-9B
	vdp_rd_n_s		<= '0'	when io_read_s = '1'   and cpu_addr_s(7 downto 2) = "100110"	else '1';	-- VDP read		=> 98-9B
	spi_cs_s			<= '1'	when io_access_s = '1' and cpu_addr_s(7 downto 1) = "1001111"	else '0';	-- SPI			=> 9E-9F
	psg_cs_s			<= '1'	when io_access_s = '1' and cpu_addr_s(7 downto 2) = "101000"	else '0';	-- PSG			=> A0-A3
	pio_cs_s			<= '1'	when io_access_s = '1' and cpu_addr_s(7 downto 2) = "101010"	else '0';	-- PPI 			=> A8-AB
	mp_cs_s			<= '1'	when io_access_s = '1' and cpu_addr_s(7 downto 2) = "111111"	else '0';	-- Mapper		=> FC-FF

	-- PSG
	psg_bc1_s	<= '1' when psg_cs_s = '1' and cpu_addr_s(0) = '0'	else '0';
	psg_bdir_s	<= '1' when psg_cs_s = '1' and wr_n_s = '0'			else '0';

	-- PIO
	pio_rd_s		<= not rd_n_s;
	pio_wr_s		<= not wr_n_s;

	-- ESCCI
	mram_cs_s	<= '1' when prim_slot_n_s(2) = '0'	else '0';		-- slot 2

	-- MUX data CPU
	d_to_cpu_s	<= 
			-- Memory
			d_from_iplrom_s			when iplrom_cs_s = '1'		else
			ram_data_i					when iplram_cs_s = '1'		else
			rom_data_i					when brom_cs_s = '1'			else
			ram_data_i					when ram_cs_s = '1'			else
			ram_data_i					when nxt_rom_cs_s = '1'		else
			d_from_exp_s				when exp_has_data_s = '1'	else
			d_from_mram_s				when mram_cs_s = '1'			else
			-- I/O
			d_from_vdp_s				when vdp_rd_n_s = '0'		else
			d_from_psg_s				when psg_cs_s = '1'			else
			d_from_pio_s				when pio_hd_s = '1'			else
			d_from_spi_s				when spi_hd_s = '1'			else
			d_from_mp_s					when mp_cs_s  = '1'			else
			d_from_swp_s				when swp_hd_s = '1'			else
			--
			bus_data_i;

	-- Slot control
	with cpu_addr_s(15 downto 14) select pslot_s <= 
		pio_port_a_s(7 downto 6)	when "11",
		pio_port_a_s(5 downto 4)	when "10",
		pio_port_a_s(3 downto 2)	when "01",
		pio_port_a_s(1 downto 0)	when others;

	prim_slot_n_s(0)	<= '0' when mreq_n_s = '0' and rfsh_n_s = '1' and pslot_s = "00"		else '1';
	prim_slot_n_s(1)	<= '0' when mreq_n_s = '0' and rfsh_n_s = '1' and pslot_s = "01"		else '1';
	prim_slot_n_s(2)	<= '0' when mreq_n_s = '0' and rfsh_n_s = '1' and pslot_s = "10"		else '1';
	prim_slot_n_s(3)	<= '0' when mreq_n_s = '0' and rfsh_n_s = '1' and pslot_s = "11"		else '1';

	-- ROMs
	iplrom_cs_s		<= '1'	when slot3_exp_n_s(3) = '0' and cpu_addr_s(15 downto 13) = "000"	else '0';
	iplrom_addr_s	<= cpu_addr_s(12 downto 0);
	brom_cs_s		<= '1'	when prim_slot_n_s(0) = '0' and cpu_addr_s(15) = '0'					else '0';	-- 0000-7FFF

	-- Mapper
	process(reset_i, clock_cpu_i)
	begin
		if reset_i = '1' then
			mp_bank0_s	<= "011";
			mp_bank1_s	<= "010";
			mp_bank2_s	<= "001";
			mp_bank3_s	<= "000";
		elsif falling_edge(clock_cpu_i) then
			if mp_cs_s = '1' and wr_n_s = '0' then
				case cpu_addr_s(1 downto 0) is
					when "00"   => mp_bank0_s <= d_from_cpu_s(2 downto 0);
					when "01"   => mp_bank1_s <= d_from_cpu_s(2 downto 0);
					when "10"   => mp_bank2_s <= d_from_cpu_s(2 downto 0);
					when others => mp_bank3_s <= d_from_cpu_s(2 downto 0);
				end case;
			end if;
		end if;
	end process;

	-- Mapper read
	d_from_mp_s <= "11111" & mp_bank0_s when cpu_addr_s(1 downto 0) = "00" else
						"11111" & mp_bank1_s when cpu_addr_s(1 downto 0) = "01" else
						"11111" & mp_bank2_s when cpu_addr_s(1 downto 0) = "10" else
						"11111" & mp_bank3_s;

	-- Mapper page
	mp_page_s	<= mp_bank0_s when cpu_addr_s(15 downto 14) = "00" else
						mp_bank1_s when cpu_addr_s(15 downto 14) = "01" else
						mp_bank2_s when cpu_addr_s(15 downto 14) = "10" else
						mp_bank3_s;

	-- RAM
	ram_data_o	<= d_from_cpu_s;
	ram_ce_o		<= ram_cs_s or iplram_cs_s or nxt_rom_cs_s or mr_ram_ce_s or (use_rom_in_ram_s and brom_cs_s);
	ram_oe_o		<= not rd_n_s;
	ram_we_o		<= '1' when wr_n_s = '0' and (ram_cs_s = '1' or mr_ram_ce_s = '1')	else
						'1' when wr_n_s = '0' and iplram_cs_s = '1' and iplram_bw_s = '0'	else
						'0';
	ram_cs_s		<= '1' when	slot3_exp_n_s(1) = '0' else '0';
	iplram_cs_s	<= '1' when slot3_exp_n_s(3) = '0' and cpu_addr_s(15 downto 14) /= "00"	else '0';

	-- IPLRAM block write
	process (por_i, clock_cpu_i)
	begin
		if por_i = '1' then
			iplram_bw_s <= '0';
		elsif falling_edge(clock_cpu_i) then
			if pio_cs_s = '1' and wr_n_s = '0' then
				iplram_bw_s <= '1';
			end if;
		end if;
	end process;

	use_rom_in_ram_s <= '1'	when hw_id_g = 5 or hw_id_g = 6	else '0';

	-- RAM map
	-- 00000-1FFFF = NEXTOR			(128K)	00xxx		(IPL pages 0-7)
	-- 20000-3FFFF = Mapper RAM	(128K)	01xxx		(IPL pages 8-15)
	-- 40000-7FFFF = SCC/Megaram	(256K)	1xxxx		(IPL pages 16-31)
	--	OR
	--	40000-5FFFF = SCC/Megaram	(128K)	10xxx		(IPL pages 16-23)
	-- 78000-7FFFF = ROM          (32K)    1111x		(IPL pages 30-31)
	process (nxt_rom_cs_s, slot3_exp_n_s, cpu_addr_s, nxt_rom_page_s,
				ram_page_s, mp_page_s, ram_cs_s, mr_ram_addr_s,
				use_rom_in_ram_s, mr_ram_ce_s, brom_cs_s)
	begin
		ram_addr_o <= (others => '0');
		if nxt_rom_cs_s = '1' then																-- Nextor (slot 3.2)
			ram_addr_o	<= "00" & nxt_rom_page_s & cpu_addr_s(13 downto 0);
		elsif slot3_exp_n_s(3) = '0' and cpu_addr_s(15 downto 14) = "01" then	-- RAM 16K (IPL) (3.3 $4000-$7FFF)
			ram_addr_o	<= "01111" & cpu_addr_s(13 downto 0);
		elsif slot3_exp_n_s(3) = '0' and cpu_addr_s(15) = '1' then					-- All RAM (IPL) (3.3 $8000-$FFFF)
			ram_addr_o	<= ram_page_s & cpu_addr_s(13 downto 0);
		elsif mr_ram_ce_s = '1' then															-- SCC/Megaram (slot 1)
			if use_rom_in_ram_s = '1' then
				ram_addr_o <= "10" & mr_ram_addr_s(16 downto 0);						
			else
				ram_addr_o	<= "1" & mr_ram_addr_s(17 downto 0);
			end if;
		elsif brom_cs_s = '1' and use_rom_in_ram_s = '1' then							-- ROM
			ram_addr_o <= "1111" & cpu_addr_s(14 downto 0);
		elsif ram_cs_s = '1' then																-- Mapper (3.1)
			ram_addr_o	<= "01" & mp_page_s  & cpu_addr_s(13 downto 0);
		else
			null;
		end if;
	end process;

	-- RAM page write
	process (reset_i, clock_cpu_i)
	begin
		if reset_i = '1' then
			ram_page_s <= (others => '1');
		elsif falling_edge(clock_cpu_i) then
			if mreq_n_s = '0' and wr_n_s = '0' and slot3_exp_n_s(3) = '0' and cpu_addr_s = X"3FFF" then
				ram_page_s <= d_from_cpu_s(4 downto 0);
			end if;
		end if;
	end process;

	-- ROM
	rom_addr_o		<= cpu_addr_s(14 downto 0);
	rom_ce_o			<= brom_cs_s;
	rom_oe_o			<= not rd_n_s;

	-- BUS
	bus_addr_o		<= cpu_addr_s;
	bus_data_o		<= d_from_cpu_s;
	bus_rd_n_o		<= rd_n_s;
	bus_wr_n_o		<= wr_n_s;
	bus_m1_n_o		<= m1_n_s;
	bus_iorq_n_o	<= iorq_n_s;
	bus_mreq_n_o	<= mreq_n_s;
	bus_sltsl1_n_o	<= prim_slot_n_s(1);
	bus_sltsl2_n_o	<= prim_slot_n_s(2);

	wait_n_s			<= m1_wait_n_s and bus_wait_n_i and not vdp_wait_s;
	int_n_s			<= bus_int_n_i and vdp_int_n_s;

	-- Debug
	D_slots_o		<= pio_port_a_s;
	D_wait_o			<= vdp_wait_s;

end architecture;