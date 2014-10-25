# -*- encoding : utf-8 -*-

require "test/unit"
require_relative "../comptes.rb"  # Ruby >= 1.9

def simple_expenses
  expenses = Depenses.new(%w(A B C D E))
  expenses.ajouter_depense('A', 15, ['A','B','C'])
  return expenses
end

def expenses_1
  expenses = Depenses.new(%w(A B C D E))
  expenses.ajouter_depense('A', 15, ['A','B','C'])
  expenses.ajouter_depense('A', 5)
  expenses.ajouter_depense('E', 30, ['A','B','E'])
  expenses.ajouter_depense('C', 14, ['C','E'])
  expenses.ajouter_depense('C', 5)
  expenses.ajouter_depense('B', 10, ['A','D'])
  return expenses
end

class TestSComptes < Test::Unit::TestCase

  # -*- Simple -*-

  def test_balance_calculation_simple
    expenses = simple_expenses()
    expected_balance = {"A"=>-10.0, "B"=>5.0, "C"=>5.0, "D"=>0.0, "E"=>0.0}
    assert_equal(Comptes.calcul_balance(expenses, 0.001), expected_balance)
  end

  def test_solving_simple
    expenses = simple_expenses()
    debts = Comptes.calcul_dettes(expenses).matrice
    expected_debts = Matrix[
      [0   ,0   ,0   ,0   ,0  ],
      [5.0 ,0   ,0   ,0   ,0  ],
      [5.0 ,0   ,0   ,0   ,0  ],
      [0   ,0   ,0   ,0   ,0  ],
      [0   ,0   ,0   ,0   ,0  ]
    ]
    assert_equal(debts, expected_debts)
  end

  # -*- Problem 1 -*-

  def test_balance_calculation_1
    expenses = expenses_1
    expected_balance = {"A"=>2.0, "B"=>7.0, "C"=>-5.0, "D"=>7.0, "E"=>-11.0}
    assert_equal(Comptes.calcul_balance(expenses, 0.001), expected_balance)
  end

  def test_solving_1_without_order
    expenses = expenses_1()
    debts = Comptes.calcul_dettes(expenses).matrice
    expected_debts = Matrix[
      [0   ,0   ,0   ,0   ,2.0],
      [0   ,0   ,5.0 ,0   ,2.0],
      [0   ,0   ,0   ,0   ,0  ],
      [0   ,0   ,0   ,0   ,7.0],
      [0   ,0   ,0   ,0   ,0  ]
    ]
    assert_equal(debts, expected_debts)
  end

  def test_solving_1_with_order
    expenses = expenses_1()
    debts = Comptes.calcul_dettes(expenses, payers_order = %w(B A C E)).matrice
    expected_debts = Matrix[
      [0   ,0   ,2.0 ,0   ,0  ],
      [0   ,0   ,3.0 ,0   ,4.0],
      [0   ,0   ,0   ,0   ,0  ],
      [0   ,0   ,0   ,0   ,7.0],
      [0   ,0   ,0   ,0   ,0  ]
    ]
    assert_equal(debts, expected_debts)
  end


end
