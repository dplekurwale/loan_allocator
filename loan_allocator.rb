#loan1 = Loan.new(1, 'property', 'A', 5000)
class Loan
  attr_accessor :id, :category, :risk_band, :amount, :allocated
  RISK_BAND  = ['A+', 'A', 'B', 'C', 'D', 'E']

  def initialize(id, category, risk_band, amount)
    @id = id
    @category = category
    @risk_band = risk_band
    @amount = amount
    @allocated = false
  end
end

# Example - criteria = [{name: 'property', percent: '40', risk_band: 'A'}, {name: 'retail'}, {name: 'medical', risk_band: 'B'}]
class Investor
  attr_accessor :name, :balance_amt, :criteria

  def initialize(name, balance_amt, criteria)
    @name = name
    @balance_amt = balance_amt
    @criteria = criteria
  end

  def update_balance_amt(amt)
    @balance_amt -= amt
  end

  def check_risk_band?(loan_risk_band)
    criteria.each do |key, values|
      values.each do |crt|
        if crt.keys.include?(:risk_band)
          grade = crt[:risk_band].slice(-1)
          if Loan::RISK_BAND.include?(grade)
            return true if crt[:risk_band] == loan_risk_band
            get_valid_bands(crt[:risk_band], grade).each do |band|
              return true if band == loan_risk_band
            end
            return false
          end
        end
      end
    end
    true
  end

  def get_valid_bands(band, grade)
    case band
    when /\A>=/
      Loan::RISK_BAND[0..Loan::RISK_BAND.index(grade)]
    when /\A>/
      Loan::RISK_BAND[0..(Loan::RISK_BAND.index(grade)-1)]
    when /\A<=/
      Loan::RISK_BAND[Loan::RISK_BAND.index(grade)..(Loan::RISK_BAND.length - 1)]
    when /\A</
      Loan::RISK_BAND[(Loan::RISK_BAND.index(grade) + 1)..(Loan::RISK_BAND.length - 1)]
    else
      []
    end
  end

  def check_amount?(loan_amt)
    criteria.each do |key, values|
      values.each do |crt|
        if crt.keys.include?(:percent)
          return balance_amt*(crt[:percent].to_f/100) >= loan_amt  
        end
      end
    end
    balance_amt >= loan_amt
  end

  def can_fund?(loan)
    fund = false
    criteria.each do |key, values|
      values.each do |crt|
        fund = crt[:name] == (loan.category) && check_risk_band?(loan.risk_band) && check_amount?(loan.amount)
        break if fund
      end
    end
    fund
  end
end

class LoanAllocation
  attr_accessor :loans, :investors

  def initialize(loans, investors)
    @loans = loans
    @investors = investors
  end

  #Allocate loans base on investor criteria
  #Return hash key as investor and value will be the array of loan
  def allocate
    investor_loans = Hash.new {|h,k| h[k] = [] }
    investors.each do |investor|
      loans.select {|loan| !loan.allocated }.each do |loan|
        if investor.can_fund?(loan)
          investor_loans[investor.name] << loan.id
          investor.update_balance_amt(loan.amount)
          loan.allocated = true
        end
        break if investor.balance_amt == 0
      end
    end
    puts investor_loans
  end
end

# Test Cases
loan1 = Loan.new(1,'property','A', 5000)
loan2 = Loan.new(2,'property','B', 4000)
loan3 = Loan.new(3,'retail','C', 3000)
loan4 = Loan.new(4,'retail','D', 1000)
loan5 = Loan.new(5,'property','A', 3000)
loan6 = Loan.new(6,'retail','B', 1000)
loan7 = Loan.new(7,'property','A', 1500)
loan8 = Loan.new(8,'property','B', 1800)
loan9 = Loan.new(9,'property','A', 3000)

investor1 = Investor.new('Bob', 10000, {criteria: [{name: 'property'}]})
investor2 = Investor.new('Susan', 5000, {criteria: [{name: 'property'}, {name: 'retail'}]})
investor3 = Investor.new('George', 3000, {criteria: [{name: 'property', risk_band: 'A'}]})
investor4 = Investor.new('Helen', 5000, {criteria: [{name: 'property', percent: 40}]})
investor5 = Investor.new('Jamie', 5000, {criteria: [{name: 'property', risk_band: '>=B'}]})

LoanAllocation.new([loan1, loan2, loan3, loan4, loan5, loan6, loan7, loan8, loan9], [investor1, investor2, investor3, investor4, investor5]).allocate
