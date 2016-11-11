--
-- Copyright (c) 2016 - Fabio Belavenuto
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
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
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
-- You are responsible for any legal issues arising from your use of this code.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
end tb;

architecture testbench of tb is

	-- test target
	component msx
	generic (
		hw_id_g			: integer								:= 0;
		hw_txt_g			: string 								:= "NONE";
		hw_version_g	: std_logic_vector(7 downto 0)	:= X"00";
		is_pal_g			: boolean								:= false
	);
	port(
		-- clocks
		clock_i				: in  std_logic;
		clock_vdp_i			: in  std_logic;
		clock_cpu_i			: in  std_logic;
		clock_psg_en_i		: in  std_logic;
		-- Turbo
		turbo_on_k_i	: in  std_logic;
		turbo_on_o		: out std_logic;
		-- Resets
		reset_i				: in  std_logic;
		por_i				: in  std_logic;
		softreset_o		: out std_logic;
		-- Options
		opt_nextor_i		: in  std_logic;
		opt_mr_type_i		: in  std_logic_vector(1 downto 0);
		-- RAM
		ram_addr_o			: out std_logic_vector(18 downto 0);	-- 512K
		ram_data_i			: in  std_logic_vector( 7 downto 0);
		ram_data_o			: out std_logic_vector( 7 downto 0);
		ram_ce_o			: out std_logic;
		ram_oe_o			: out std_logic;
		ram_we_o			: out std_logic;
		-- ROM
		rom_addr_o			: out std_logic_vector(14 downto 0);	-- 32K
		rom_data_i			: in  std_logic_vector( 7 downto 0);
		rom_ce_o			: out std_logic;
		rom_oe_o			: out std_logic;
		-- External bus
		bus_addr_o			: out std_logic_vector(15 downto 0);
		bus_data_i			: in  std_logic_vector( 7 downto 0);
		bus_data_o			: out std_logic_vector( 7 downto 0);
		bus_rd_n_o			: out std_logic;
		bus_wr_n_o			: out std_logic;
		bus_m1_n_o			: out std_logic;
		bus_iorq_n_o		: out std_logic;
		bus_mreq_n_o		: out std_logic;
		bus_sltsl1_n_o		: out std_logic;
		bus_sltsl2_n_o		: out std_logic;
		bus_wait_n_i		: in  std_logic;
		bus_nmi_n_i			: in  std_logic;
		bus_int_n_i			: in  std_logic;
		-- VDP VRAM
		vram_addr_o			: out std_logic_vector(13 downto 0);	-- 16K
		vram_data_i			: in  std_logic_vector( 7 downto 0);
		vram_data_o			: out std_logic_vector( 7 downto 0);
		vram_ce_o			: out std_logic;
		vram_oe_o			: out std_logic;
		vram_we_o			: out std_logic;
		-- Keyboard
		rows_o				: out std_logic_vector(3 downto 0);
		cols_i				: in  std_logic_vector(7 downto 0)		:= (others => '1');
		caps_en_o			: out std_logic;
		-- Audio
		audio_scc_o		: out signed(14 downto 0);
		audio_psg_o		: out unsigned(7 downto 0);
		beep_o				: out std_logic;
		-- K7
		k7_motor_o			: out std_logic;
		k7_audio_o			: out std_logic;
		k7_audio_i			: in  std_logic;
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
		rgb_r_o				: out std_logic_vector( 3 downto 0);
		rgb_g_o				: out std_logic_vector( 3 downto 0);
		rgb_b_o				: out std_logic_vector( 3 downto 0);
		hsync_n_o			: out std_logic;
		vsync_n_o			: out std_logic;
		csync_n_o			: out std_logic;
		-- SPI/SD
		spi_cs_n_o			: out std_logic;
		spi_sclk_o			: out std_logic;
		spi_mosi_o			: out std_logic;
		spi_miso_i			: in  std_logic								:= '0';
		-- DEBUG
		D_wait_o			: out std_logic;
		D_slots_o		: out std_logic_vector( 7 downto 0)
	);
	end component;

	component clocks
	port (
		clock_i			: in  std_logic;				-- 21 MHz
		por_i				: in  std_logic;
		turbo_on_i		: in  std_logic;				-- 0 = 3.57, 1 = 7.15
		clock_vdp_o		: out std_logic;
		clock_cpu_o		: out std_logic;
		clock_psg_en_o	: out std_logic;
		clock_3m_o		: out std_logic
	);
	end component;

	signal tb_end				: std_logic;
	signal clock_s				: std_logic;
	signal clock_vdp_s			: std_logic;
	signal clock_cpu_s			: std_logic;
	signal clock_psg_en_s		: std_logic;
	signal clock_3m_s			: std_logic;
	signal turbo_on_k_s			: std_logic;
	signal turbo_on_s			: std_logic;
	signal reset_s				: std_logic;
	signal por_s				: std_logic;
	signal softreset_s			: std_logic;
	signal opt_nextor_s			: std_logic;
	signal opt_mr_type_s		: std_logic_vector(1 downto 0);
	signal ram_addr_s			: std_logic_vector(18 downto 0);	-- 512K
	signal ram_data_i_s			: std_logic_vector( 7 downto 0);
	signal ram_data_o_s			: std_logic_vector( 7 downto 0);
	signal ram_ce_s				: std_logic;
	signal ram_oe_s				: std_logic;
	signal ram_we_s				: std_logic;
	signal rom_addr_s			: std_logic_vector(14 downto 0);	-- 32K
	signal rom_data_s			: std_logic_vector( 7 downto 0);
	signal rom_ce_s				: std_logic;
	signal rom_oe_s				: std_logic;
	signal bus_addr_s			: std_logic_vector(15 downto 0);
	signal bus_data_i_s			: std_logic_vector( 7 downto 0);
	signal bus_data_o_s			: std_logic_vector( 7 downto 0);
	signal bus_rd_n_s			: std_logic;
	signal bus_wr_n_s			: std_logic;
	signal bus_m1_n_s			: std_logic;
	signal bus_iorq_n_s			: std_logic;
	signal bus_mreq_n_s			: std_logic;
	signal bus_sltsl1_n_s		: std_logic;
	signal bus_sltsl2_n_s		: std_logic;
	signal bus_wait_n_s			: std_logic;
	signal bus_nmi_n_s			: std_logic;
	signal bus_int_n_s			: std_logic;
	signal vram_addr_s			: std_logic_vector(13 downto 0);	-- 16K
	signal vram_data_i_s			: std_logic_vector( 7 downto 0);
	signal vram_data_o_s			: std_logic_vector( 7 downto 0);
	signal vram_ce_s			: std_logic;
	signal vram_oe_s			: std_logic;
	signal vram_we_s			: std_logic;
	signal rows_s				: std_logic_vector(3 downto 0);
	signal cols_s				: std_logic_vector(7 downto 0)		:= (others => '1');
	signal caps_en_s			: std_logic;
	signal audio_scc_s			: signed(14 downto 0);
	signal audio_psg_s			: unsigned(7 downto 0);
	signal beep_s				: std_logic;
	signal k7_motor_s			: std_logic;
	signal k7_audio_o_s			: std_logic;
	signal k7_audio_i_s			: std_logic;
	signal joy1_up_s			: std_logic;
	signal joy1_down_s			: std_logic;
	signal joy1_left_s			: std_logic;
	signal joy1_right_s			: std_logic;
	signal joy1_btn1_s			: std_logic;
	signal joy1_btn2_s			: std_logic;
	signal joy1_out_s			: std_logic;
	signal joy2_up_s			: std_logic;
	signal joy2_down_s			: std_logic;
	signal joy2_left_s			: std_logic;
	signal joy2_right_s			: std_logic;
	signal joy2_btn1_s			: std_logic;
	signal joy2_btn2_s			: std_logic;
	signal joy2_out_s			: std_logic;
	signal col_s				: std_logic_vector( 3 downto 0);
	signal rgb_r_s				: std_logic_vector( 3 downto 0);
	signal rgb_g_s				: std_logic_vector( 3 downto 0);
	signal rgb_b_s				: std_logic_vector( 3 downto 0);
	signal hsync_n_s			: std_logic;
	signal vsync_n_s			: std_logic;
	signal csync_n_s			: std_logic;
	signal spi_cs_n_s			: std_logic;
	signal spi_sclk_s			: std_logic;
	signal spi_mosi_s			: std_logic;
	signal spi_miso_s			: std_logic								:= '0';
	signal D_slots_s			: std_logic_vector( 7 downto 0);

begin

	--  instance
	u_target: msx
	generic map (
		hw_id_g			=> 255,
		hw_txt_g			=> "SIMUL",
		hw_version_g	=> X"10",
		is_pal_g		=> false
	)
	port map(
		-- clocks
		clock_i				=> clock_s,
		clock_vdp_i			=> clock_vdp_s,
		clock_cpu_i			=> clock_cpu_s,
		clock_psg_en_i		=> clock_psg_en_s,
		-- Turbo
		turbo_on_k_i		=> turbo_on_k_s,
		turbo_on_o			=> turbo_on_s,
		-- Resets
		reset_i				=> reset_s,
		por_i				=> por_s,
		softreset_o			=> softreset_s,
		-- Options
		opt_nextor_i		=> opt_nextor_s,
		opt_mr_type_i		=> opt_mr_type_s,
		-- RAM
		ram_addr_o			=> ram_addr_s,
		ram_data_i			=> ram_data_i_s,
		ram_data_o			=> ram_data_o_s,
		ram_ce_o			=> ram_ce_s,
		ram_oe_o			=> ram_oe_s,
		ram_we_o			=> ram_we_s,
		-- ROM
		rom_addr_o			=> rom_addr_s,
		rom_data_i			=> rom_data_s,
		rom_ce_o			=> rom_ce_s,
		rom_oe_o			=> rom_oe_s,
		-- External bus
		bus_addr_o			=> bus_addr_s,
		bus_data_i			=> bus_data_i_s,
		bus_data_o			=> bus_data_o_s,
		bus_rd_n_o			=> bus_rd_n_s,
		bus_wr_n_o			=> bus_wr_n_s,
		bus_m1_n_o			=> bus_m1_n_s,
		bus_iorq_n_o		=> bus_iorq_n_s,
		bus_mreq_n_o		=> bus_mreq_n_s,
		bus_sltsl1_n_o		=> bus_sltsl1_n_s,
		bus_sltsl2_n_o		=> bus_sltsl2_n_s,
		bus_wait_n_i		=> bus_wait_n_s,
		bus_nmi_n_i			=> bus_nmi_n_s,
		bus_int_n_i			=> bus_int_n_s,
		-- VDP VRAM
		vram_addr_o			=> vram_addr_s,
		vram_data_i			=> vram_data_i_s,
		vram_data_o			=> vram_data_o_s,
		vram_ce_o			=> vram_ce_s,
		vram_oe_o			=> vram_oe_s,
		vram_we_o			=> vram_we_s,
		-- Keyboard
		rows_o				=> rows_s,
		cols_i				=> cols_s,
		caps_en_o			=> caps_en_s,
		-- Audio
		audio_scc_o			=> audio_scc_s,
		audio_psg_o			=> audio_psg_s,
		beep_o				=> beep_s,
		-- K7
		k7_motor_o			=> k7_motor_s,
		k7_audio_o			=> k7_audio_o_s,
		k7_audio_i			=> k7_audio_i_s,
		-- Joystick
		joy1_up_i			=> joy1_up_s,
		joy1_down_i			=> joy1_down_s,
		joy1_left_i			=> joy1_left_s,
		joy1_right_i		=> joy1_right_s,
		joy1_btn1_io		=> joy1_btn1_s,
		joy1_btn2_io		=> joy1_btn2_s,
		joy1_out_o			=> joy1_out_s,
		joy2_up_i			=> joy2_up_s,
		joy2_down_i			=> joy2_down_s,
		joy2_left_i			=> joy2_left_s,
		joy2_right_i		=> joy2_right_s,
		joy2_btn1_io		=> joy2_btn1_s,
		joy2_btn2_io		=> joy2_btn2_s,
		joy2_out_o			=> joy2_out_s,
		-- Video
		col_o				=> col_s,
		rgb_r_o				=> rgb_r_s,
		rgb_g_o				=> rgb_g_s,
		rgb_b_o				=> rgb_b_s,
		hsync_n_o			=> hsync_n_s,
		vsync_n_o			=> vsync_n_s,
		csync_n_o			=> csync_n_s,
		-- SPI/SD
		spi_cs_n_o			=> spi_cs_n_s,
		spi_sclk_o			=> spi_sclk_s,
		spi_mosi_o			=> spi_mosi_s,
		spi_miso_i			=> spi_miso_s,
		-- DEBUG
		D_wait_o			=> open,
		D_slots_o			=> D_slots_s
	);

	u_clocks: clocks
	port map (
		clock_i			=> clock_s,
		por_i			=> por_s,
		turbo_on_i		=> turbo_on_s,
		clock_vdp_o		=> clock_vdp_s,
		clock_cpu_o		=> clock_cpu_s,
		clock_psg_en_o	=> clock_psg_en_s,
		clock_3m_o		=> clock_3m_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for 23.280418648974914278006471677019 ns;
		clock_s <= '1';
		wait for 23.280418648974914278006471677019 ns;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		turbo_on_k_s		<= '0';
		opt_nextor_s		<= '0';
		opt_mr_type_s		<= "00";
		ram_data_i_s		<= (others => '0');
		rom_data_s			<= (others => '0');
		bus_data_i_s		<= (others => '0');
		bus_wait_n_s		<= '1';
		bus_nmi_n_s			<= '1';
		bus_int_n_s			<= '1';
		vram_data_i_s		<= (others => '0');
		cols_s				<= (others => '1');
		k7_audio_i_s		<= '0';
		joy1_up_s			<= '1';
		joy1_down_s			<= '1';
		joy1_left_s			<= '1';
		joy1_right_s		<= '1';
		joy1_btn1_s			<= '1';
		joy1_btn2_s			<= '1';
		joy2_up_s			<= '1';
		joy2_down_s			<= '1';
		joy2_left_s			<= '1';
		joy2_right_s		<= '1';
		joy2_btn1_s			<= '1';
		joy2_btn2_s			<= '1';
		spi_miso_s			<= '0';

		-- reset
		por_s		<= '1';
		reset_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		por_s		<= '0';
		reset_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		-- Liga turbo
		turbo_on_k_s <= '1';
		wait for 1 us;
		turbo_on_k_s <= '0';

		wait for 3.5 ms;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;