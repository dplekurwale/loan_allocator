require '.\spec_helper'

describe Loan do
  describe '#initialize' do
    it 'should initialize Loan class' do
      loan = Loan.new(1,'property','A', 5000)
      expect(loan.id).to eq(1)
      expect(loan.category).to eq('property')
      expect(loan.risk_band).to eq('A')
      expect(loan.amount).to eq(5000)
      expect(loan.allocated).to be_falsy 
    end
  end
end

describe Investor do
  let(:loan) { Loan.new(1,'property','A', 5000) }
  let(:investor1) { Investor.new('Bob', 10000, {criteria: [{name: 'property'}]}) }
  let(:investor2) { Investor.new('George', 3000, {criteria: [{name: 'property', risk_band: 'A'}]}) }
  let(:investor3) { Investor.new('Jamie', 5000, {criteria: [{name: 'property', risk_band: '>=B'}]})}
  let(:investor4) { Investor.new('Helen', 5000, {criteria: [{name: 'property', risk_band: '<=B'}]})}

  describe "#initialize" do
    it 'should initialize Investor class' do
      expect(investor1.name).to eq('Bob')
      expect(investor1.balance_amt).to eq(10000)
      expect(investor1.criteria).to eq({criteria: [{name: 'property'}]})
    end
  end

  describe '#update_balance_amt' do
    it 'should update investor balance amount' do
      investor1.update_balance_amt(2000)
      expect(investor1.balance_amt).to eq(8000)
      expect(investor2.balance_amt).to eq(3000)
    end
  end

  describe '#check_risk_band?(loan_risk_band)' do
    it 'should check for valid investor risk band' do
      expect(investor2.check_risk_band?('A')).to be_truthy
    end

    it 'should return true for investor with no risk_band criteria' do
      expect(investor1.check_risk_band?('')).to be_truthy
    end
  end

  describe '#get_valid_bands(band, grade)' do
    it 'should return valid bands for investor' do
      expect(investor3.get_valid_bands('>=B', 'B')).to eq(['A+', 'A', 'B'])
      expect(investor4.get_valid_bands('<=B', 'B')).to eq(['B', 'C', 'D', 'E'])
    end
  end

  describe '#check_amount?(loan_amt)' do
    it 'should check if investor balance amount is enough to invest in loan' do
      expect(investor1.check_amount?(9000)).to be_truthy
      expect(investor2.check_amount?(4000)).to be_falsy
      expect(investor3.check_amount?(4000)).to be_truthy
    end
  end

  describe 'can_fund?(loan)' do
    it 'should check if investor can fund loan' do
      expect(investor1.can_fund?(loan)).to be_truthy
      expect(investor2.can_fund?(loan)).to be_falsy
      expect(investor3.can_fund?(loan)).to be_truthy
      expect(investor4.can_fund?(loan)).to be_falsy
    end
  end
end

describe LoanAllocation do
  let(:loan1) { Loan.new(1,'property','A', 5000) }
  let(:loan2) { Loan.new(2,'property','B', 4000) }
  let(:loan3) { Loan.new(3,'retail','C', 3000) }
  let(:investor1) { Investor.new('Bob', 10000, {criteria: [{name: 'property'}]}) }
  let(:investor2) { Investor.new('George', 3000, {criteria: [{name: 'retail', risk_band: '>=C'}]}) }
  let(:loan_allocation) { LoanAllocation.new([loan1, loan2, loan3], [investor1, investor2]) }

  describe '#initialize' do
    it 'should initialize LoanAllocation class' do
      expect(loan_allocation.loans).to eq([loan1, loan2, loan3])
      expect(loan_allocation.investors).to eq([investor1, investor2])
    end
  end

  describe '#allocate' do
    it 'should allocate loans to investors depending on the criteria' do
      expect do
        loan_allocation.allocate
      end.to output("{\"Bob\"=>[1, 2], \"George\"=>[3]}\n").to_stdout
    end 
  end
end