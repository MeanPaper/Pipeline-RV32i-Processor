simSetSimulator "-vcssv" -exec \
           "/home/dl35/ece411/mp_superscalar/dadda_tree/sim/dadda_tree_dut_tb" \
           -args
debImport "-dbdir" \
          "/home/dl35/ece411/mp_superscalar/dadda_tree/sim/dadda_tree_dut_tb.daidir"
debLoadSimResult /home/dl35/ece411/mp_superscalar/dadda_tree/sim/dump.fsdb
wvCreateWindow
srcHBSelect "dadda_tree_dut_tb.dut_fin" -win $_nTrace1
srcHBSelect "dadda_tree_dut_tb.dut_fin" -win $_nTrace1
srcSetScope "dadda_tree_dut_tb.dut_fin" -delim "." -win $_nTrace1
srcHBSelect "dadda_tree_dut_tb.dut_fin" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 4 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 4 -pos 1 -win $_nTrace1
srcAction -pos 3 5 1 -win $_nTrace1 -name "clk" -ctrlKey off
srcHBSelect "dadda_tree_dut_tb.dut_fin" -win $_nTrace1
srcHBSelect "dadda_tree_dut_tb.dut_fin" -win $_nTrace1
srcSetScope "dadda_tree_dut_tb.dut_fin" -delim "." -win $_nTrace1
srcHBSelect "dadda_tree_dut_tb.dut_fin" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 4 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "rst" -line 5 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 20.517451 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 20.152619 -snap {("G1" 1)}
wvZoomAll -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "m_alu_active" -line 11 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 9.416138 -snap {("G2" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "m_ex_alu_done" -line 13 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "m_ex_alu_done" -line 13 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "m_ex_alu_done" -line 13 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "m_ex_alu_done" -line 13 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "m_ex_alu_done" -line 13 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
