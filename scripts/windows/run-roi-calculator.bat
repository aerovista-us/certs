@echo off
REM NXCore ROI Calculator
REM Calculates ROI, payback period, and revenue projections

echo.
echo ========================================
echo    NXCore Infrastructure ROI Calculator
echo ========================================
echo.

echo Choose an option:
echo 1. Run full ROI analysis
echo 2. Calculate phase ROI
echo 3. Show revenue projection
echo 4. Show implementation timeline
echo 5. Exit
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo Running full ROI analysis...
    python scripts\roi-calculator.py
) else if "%choice%"=="2" (
    echo.
    echo Calculating phase ROI...
    python -c "from scripts.roi_calculator import NXCoreROICalculator; calc = NXCoreROICalculator(); calc.print_phase_analysis()"
) else if "%choice%"=="3" (
    echo.
    echo Showing revenue projection...
    python -c "from scripts.roi_calculator import NXCoreROICalculator; calc = NXCoreROICalculator(); calc.print_revenue_projection()"
) else if "%choice%"=="4" (
    echo.
    echo Showing implementation timeline...
    python -c "from scripts.roi_calculator import NXCoreROICalculator; calc = NXCoreROICalculator(); calc.print_implementation_timeline()"
) else if "%choice%"=="5" (
    echo.
    echo Exiting...
    exit /b 0
) else (
    echo.
    echo Invalid choice. Please run the script again.
    pause
    exit /b 1
)

echo.
echo Press any key to continue...
pause >nul
