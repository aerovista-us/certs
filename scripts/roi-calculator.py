#!/usr/bin/env python3
"""
NXCore Infrastructure ROI Calculator
Calculates ROI, payback period, and revenue projections
"""

import sys
from datetime import datetime, timedelta

class NXCoreROICalculator:
    def __init__(self):
        self.investment_phases = {
            'Phase 1': {
                'name': 'Critical Fixes',
                'investment': 5000,
                'duration_months': 1,
                'monthly_benefit': 17600,
                'description': 'Fix Traefik middleware and service issues'
            },
            'Phase 2': {
                'name': 'System Enhancement',
                'investment': 10000,
                'duration_months': 2,
                'monthly_benefit': 28400,
                'description': 'Enhanced monitoring and automation'
            },
            'Phase 3': {
                'name': 'PC Integration',
                'investment': 16000,
                'duration_months': 3,
                'monthly_benefit': 44200,
                'description': 'Stakeholder PC imaging and management'
            }
        }
        
        self.revenue_streams = {
            'Internal Efficiency': {
                'year_1': 1190400,
                'year_2': 1190400,
                'year_3': 1190400,
                'description': 'Productivity gains and admin time savings'
            },
            'IaaS Revenue': {
                'year_1': 0,
                'year_2': 360000,
                'year_3': 720000,
                'description': 'Infrastructure as a Service'
            },
            'Managed Services': {
                'year_1': 0,
                'year_2': 500000,
                'year_3': 1500000,
                'description': 'Managed infrastructure services'
            },
            'Consulting': {
                'year_1': 0,
                'year_2': 200000,
                'year_3': 500000,
                'description': 'Consulting and professional services'
            },
            'Training': {
                'year_1': 0,
                'year_2': 200000,
                'year_3': 500000,
                'description': 'Training and certification programs'
            },
            'Licensing': {
                'year_1': 0,
                'year_2': 100000,
                'year_3': 500000,
                'description': 'Technology licensing revenue'
            }
        }

    def calculate_phase_roi(self, phase_name):
        """Calculate ROI for a specific phase"""
        phase = self.investment_phases[phase_name]
        investment = phase['investment']
        monthly_benefit = phase['monthly_benefit']
        
        # Calculate payback period
        payback_days = (investment / monthly_benefit) * 30
        
        # Calculate annual ROI
        annual_benefit = monthly_benefit * 12
        roi_percentage = (annual_benefit / investment) * 100
        
        return {
            'phase': phase_name,
            'investment': investment,
            'monthly_benefit': monthly_benefit,
            'annual_benefit': annual_benefit,
            'payback_days': payback_days,
            'roi_percentage': roi_percentage
        }

    def calculate_total_roi(self):
        """Calculate total ROI for all phases"""
        total_investment = sum(phase['investment'] for phase in self.investment_phases.values())
        
        # Calculate total revenue over 3 years
        total_revenue = 0
        for year in [1, 2, 3]:
            year_revenue = sum(stream[f'year_{year}'] for stream in self.revenue_streams.values())
            total_revenue += year_revenue
        
        # Calculate ROI
        net_benefit = total_revenue - total_investment
        roi_percentage = (net_benefit / total_investment) * 100
        
        return {
            'total_investment': total_investment,
            'total_revenue': total_revenue,
            'net_benefit': net_benefit,
            'roi_percentage': roi_percentage
        }

    def generate_revenue_projection(self):
        """Generate 3-year revenue projection"""
        projection = {}
        
        for year in [1, 2, 3]:
            year_revenue = {}
            total_year_revenue = 0
            
            for stream_name, stream_data in self.revenue_streams.items():
                revenue = stream_data[f'year_{year}']
                year_revenue[stream_name] = revenue
                total_year_revenue += revenue
            
            projection[f'year_{year}'] = {
                'streams': year_revenue,
                'total': total_year_revenue
            }
        
        return projection

    def print_phase_analysis(self):
        """Print detailed phase analysis"""
        print("=" * 80)
        print("NXCore Infrastructure - Phase Analysis")
        print("=" * 80)
        print()
        
        for phase_name in self.investment_phases.keys():
            roi_data = self.calculate_phase_roi(phase_name)
            phase_info = self.investment_phases[phase_name]
            
            print(f"📊 {phase_info['name']} ({phase_name})")
            print(f"   Description: {phase_info['description']}")
            print(f"   Investment: ${roi_data['investment']:,}")
            print(f"   Monthly Benefit: ${roi_data['monthly_benefit']:,}")
            print(f"   Annual Benefit: ${roi_data['annual_benefit']:,}")
            print(f"   Payback Period: {roi_data['payback_days']:.1f} days")
            print(f"   ROI: {roi_data['roi_percentage']:.1f}%")
            print()

    def print_revenue_projection(self):
        """Print 3-year revenue projection"""
        print("=" * 80)
        print("NXCore Infrastructure - Revenue Projection")
        print("=" * 80)
        print()
        
        projection = self.generate_revenue_projection()
        
        for year in [1, 2, 3]:
            year_data = projection[f'year_{year}']
            print(f"📈 Year {year} Revenue: ${year_data['total']:,}")
            print()
            
            for stream_name, revenue in year_data['streams'].items():
                if revenue > 0:
                    stream_info = self.revenue_streams[stream_name]
                    print(f"   {stream_name}: ${revenue:,}")
                    print(f"      {stream_info['description']}")
            print()

    def print_total_roi(self):
        """Print total ROI analysis"""
        print("=" * 80)
        print("NXCore Infrastructure - Total ROI Analysis")
        print("=" * 80)
        print()
        
        total_roi = self.calculate_total_roi()
        
        print(f"💰 Total Investment: ${total_roi['total_investment']:,}")
        print(f"💰 Total Revenue (3 years): ${total_roi['total_revenue']:,}")
        print(f"💰 Net Benefit: ${total_roi['net_benefit']:,}")
        print(f"💰 ROI: {total_roi['roi_percentage']:.1f}%")
        print()
        
        # Calculate payback period for total investment
        phase_1_roi = self.calculate_phase_roi('Phase 1')
        total_payback_days = total_roi['total_investment'] / phase_1_roi['monthly_benefit'] * 30
        print(f"⏱️  Total Payback Period: {total_payback_days:.1f} days")
        print()

    def print_implementation_timeline(self):
        """Print implementation timeline"""
        print("=" * 80)
        print("NXCore Infrastructure - Implementation Timeline")
        print("=" * 80)
        print()
        
        current_date = datetime.now()
        
        for phase_name, phase_info in self.investment_phases.items():
            start_date = current_date
            end_date = current_date + timedelta(days=phase_info['duration_months'] * 30)
            
            print(f"🚀 {phase_info['name']} ({phase_name})")
            print(f"   Start Date: {start_date.strftime('%Y-%m-%d')}")
            print(f"   End Date: {end_date.strftime('%Y-%m-%d')}")
            print(f"   Duration: {phase_info['duration_months']} months")
            print(f"   Investment: ${phase_info['investment']:,}")
            print(f"   Monthly Benefit: ${phase_info['monthly_benefit']:,}")
            print()
            
            current_date = end_date

    def print_monetization_strategy(self):
        """Print monetization strategy"""
        print("=" * 80)
        print("NXCore Infrastructure - Monetization Strategy")
        print("=" * 80)
        print()
        
        print("💼 Revenue Streams:")
        print()
        
        for stream_name, stream_data in self.revenue_streams.items():
            print(f"📊 {stream_name}")
            print(f"   Year 1: ${stream_data['year_1']:,}")
            print(f"   Year 2: ${stream_data['year_2']:,}")
            print(f"   Year 3: ${stream_data['year_3']:,}")
            print(f"   Description: {stream_data['description']}")
            print()

    def run_full_analysis(self):
        """Run complete ROI analysis"""
        print("🎯 NXCore Infrastructure ROI Calculator")
        print("=" * 80)
        print()
        
        self.print_phase_analysis()
        self.print_revenue_projection()
        self.print_total_roi()
        self.print_implementation_timeline()
        self.print_monetization_strategy()
        
        print("=" * 80)
        print("✅ Analysis Complete!")
        print("=" * 80)

def main():
    """Main function"""
    calculator = NXCoreROICalculator()
    calculator.run_full_analysis()

if __name__ == "__main__":
    main()
