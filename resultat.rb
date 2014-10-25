require 'rubygems'


class Resultat

  attr_accessor :matrice  # Matrice des dettes
  attr_accessor :participants

  # participants : Array of participants names
  # matrice : Matric résultats
  def initialize(participants, matrice)
    @participants = participants
    @matrice = matrice
  end

  def to_s
    # longueur du prénom le plus long
    largeur = [@participants.sort_by {|e| e.size}.last.size + 2, 6].max + 1
    # première ligne
    res = ' ' * (largeur)
    res << @participants.collect {|key|
      key.ljust(largeur - 1)
    }.join(' ') + "\n"

    # autres lignes
    noms_tmp = @participants.clone
    noms_tmp.reverse!
    @matrice.row_vectors.each do |row|
      res << noms_tmp.pop.ljust(largeur)
      res << row.collect { |x|
        s = "%.1f" % x
        s = '0' if x.zero?
        s.ljust(largeur)
      }.to_a.join('') + "\n"
    end
    return res
  end

end
