# Verification Environment: Event Marker Testbench

This directory contains the behavioral simulation testbench for the `event_marker` module, developed in Verilog for the AMD Vivado Simulator (`xsim`).

## 📁 File Manifest

| File | Language | Purpose |
|:---|:---:|:---|
| [`tb_event_marker.v`](tb_event_marker.v) | Verilog (IEEE 1364) | Top-level testbench executing reset, noise rejection, and timed pulse verification |

---

## 🎯 Verification Objectives & Test Plan

The testbench is structured to thoroughly evaluate three distinct functional behaviors:

| Scenario | Stimulus Sequence | Expected Result | Pass Criteria |
|:---|:---|:---|:---|
| **Scenario 1: Reset Behavior** | Assert `rst = 1` for 100 ns (10 clock cycles), then deassert. | `wait_counter` and `pulse` must remain `0`. | Zero spurious output pulses. |
| **Scenario 2: Glitch / Under-Duration Rejection (Negative Test)** | Assert `start = 1` for **90 ns** (9 clock cycles), then drop to `0`. | Counter increments to `9`, resets to `0` upon deassertion. `pulse` remains `0`. | Zero pulse generation for runt pulses $< \text{wait\_time}$. |
| **Scenario 3: Qualified Event Marker (Positive Test)** | Assert `start = 1` for **110 ns** (11 clock cycles), exceeding `wait_time = 10`. | `pulse` asserts high for exactly **1 clock cycle (10 ns)** at $T = 100\text{ ns}$ after `start` goes high. | Exactly one single-cycle pulse observed at 100 ns mark. |

---

## ⏱️ Testbench Timing & Stimulus Code

```verilog
`timescale 1ns / 1ps

module tb_event_marker;
    reg clk;
    reg rst;
    reg start;
    wire pulse;

    // Instantiate Unit Under Test (UUT)
    event_marker #(
        .counter_width (4),
        .wait_time     (10)
    ) event_marker_inst (
        .clk   (clk),
        .rst   (rst),
        .start (start),
        .pulse (pulse)
    );

    // 100 MHz Clock Generation (T = 10 ns)
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst   = 0;
        start = 0;
        
        // --- Scenario 1: Reset Sequence ---
        #10;
        rst   = 1;
        #100;
        rst   = 0;
        
        // --- Scenario 2: Under-duration Pulse Rejection ---
        #1000;
        start = 1;
        #90;       // Held for 9 clock cycles (less than wait_time = 10)
        start = 0;
        
        // --- Scenario 3: Qualified Timed Event Marker ---
        #100;
        start = 1;
        #110;      // Held for 11 clock cycles (exceeds wait_time = 10)
        start = 0;
    end
endmodule
```

---

## 🔍 Detailed Stimulus Timeline

```text
Time (ns)       Action                                          Expected Hardware Reaction
----------------------------------------------------------------------------------------------------
0 ns            Initialize signals (clk=0, rst=0, start=0)      Idle state, pulse = 0, wait_counter = 0
10 ns           Assert rst = 1                                  Synchronous reset active
110 ns          Deassert rst = 0                                System enters normal idle operation
1110 ns         Assert start = 1                                wait_counter starts incrementing (1, 2, ..., 9)
1200 ns (90ns)  Deassert start = 0                              wait_counter resets to 0. pulse stays 0!
1300 ns         Idle delay between tests                        wait_counter = 0, pulse = 0
1305 ns         Assert start = 1                                wait_counter increments (1, 2, ..., 9, a)
1405 ns (100ns) wait_counter reaches 10 ('a')                   pulse asserts high (1'b1)!
1415 ns (110ns) 1 clock cycle elapsed                           pulse deasserts to 0. wait_counter resets to 0.
1420 ns         Deassert start = 0                              Idle returned.
```

---

## 🚀 Running Behavioral Simulation in AMD Vivado

### GUI Execution
1. Open the project in **Vivado 2023.2** (or 2024.x).
2. Set `tb_event_marker` as the top module under **Simulation Sources**.
3. In the Flow Navigator, click **Run Simulation $\rightarrow$ Run Behavioral Simulation**.
4. In the waveform viewer:
   * Select `clk`, `rst`, `start`, `pulse`, and `wait_counter[3:0]`.
   * Set `wait_counter[3:0]` radix to **Hexadecimal** or **Unsigned Decimal**.
5. Run the simulation for `2 us` (`run 2us;`).

### Tcl Console One-Liner
```tcl
launch_simulation -mode behavioral
run 2000 ns
```

Refer to [`02_RESULTS/README.md`](../02_RESULTS/README.md) for full screenshots and detailed waveform timing analysis.
