#!/bin/bash

sudo pcie_rescan.sh
run_model -m /models/m1a/2290/YoloV7/YoloV7.dxnn -b -l 300
