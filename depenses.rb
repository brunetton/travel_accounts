# -*- encoding : utf-8 -*-

require 'rubygems'
require 'matrix'

class Depenses

  attr_accessor :depenses
  attr_accessor :participants

  def initialize(donnees=nil)
    case donnees.class.to_s
    when 'Array'
      @participants = donnees
      @depenses = []
    when 'ooReader'
      @participants = donnees.participants
      @depenses = donnees.depenses
    when 'NilClass'
    else
      raise "Objet de la classe ooReader ou Array attendu, reçu : #{oo_reader.class}"
    end
  end

  def nombre_participants
    return @participants.size
  end

  # ajoute une dépense
  # pour_qui :
  #   - String contenant le prénom de la personne concerné dans le cas d'une dette perso
  #     'Lau'
  #   - Array des personnes concernées
  #     ['Lau, 'Bru']
  #  ou
  #   - :tous
  def ajouter_depense(qui, combien, pour_qui=nil, pourquoi = nil)
    raise "'#{qui}' doit être de type String, et non #{qui.class}" unless qui.class == String
    raise "l'argument 'combien' est Nil" if combien.nil?
    if pour_qui.class == NilClass
      pour_qui = :tous
    else
      raise "type de donnée incorrecte : #{pour_qui.class}" unless [String, Array, Symbol].include?(pour_qui.class)
    end
    pour_qui = Array(pour_qui) unless pour_qui == :tous
    [qui, pour_qui].flatten.each do |prenom|
      next if prenom == :tous
      if not @participants.include?(prenom)
        raise "prénom inconnu : '#{prenom}'. Les prénoms annoncés en début de fichier sont {#{@participants.join(', ')}}" \
             + "\n#{qui} - #{combien} - #{pourquoi} - #{pour_qui}"
      end
    end
    pour_qui = [pour_qui] if pour_qui.class == String
    @depenses << {
      :qui => qui,
      :combien => combien,
      :pour_qui => pour_qui,
      :pourquoi => pourquoi
    }
  end

  # renvoie le total dépensé par un participant
  def total_depenses(prenom)
    depenses = @depenses.select{|e| e[:qui] == prenom}.inject(0.0){|t,e| t+e[:combien]}
  end

  # renvoie l'index du participant
  def index_participant(prenom)
    index = @participants.index(prenom)
    raise "index du participant '#{prenom}' non trouvé !" unless index
    return index
  end

  # renvoie le total dû par un participant
  def total_a_payer_par(prenom)
    return @depenses.select{|e|
      e[:pour_qui] == :tous or e[:pour_qui].include?(prenom)
    }.inject(0.0){|total, e|
      nb_participants_concernes = (e[:pour_qui] == :tous ? nombre_participants : e[:pour_qui].size)
      raise 'nil' if nb_participants_concernes.nil?
      total + e[:combien] / nb_participants_concernes.to_f
    }
  end

  # renvoie le total que devrait reçevoir un participant pour être remboursé de ses prêts aux autres
  def total_a_recevoir_par(prenom)
    return @depenses.select{|e|
      e[:qui] == prenom
    }.inject(0.0){|total, e|
      nb_participants_concernes = (e[:pour_qui] == :tous ? nombre_participants : e[:pour_qui].size)
      raise 'nil' if nb_participants_concernes.nil?
      total + e[:combien] / nb_participants_concernes.to_f
    }
  end

  def select
    @depenses.select do |attr|
      yield(attr)
    end
  end

  def each
    @depenses.each do |attr|
      yield(attr)
    end
  end

  def each_with_index
    @depenses.each_with_index do |attr, index|
      yield(attr, index)
    end
  end

  def to_s
    s=''
    @depenses.each do |depense|
      s << "    #{depense[:qui]} a dépensé #{depense[:combien]} pour "
      s << (depense[:pour_qui] == :tous ? 'tout le monde' : "#{depense[:pour_qui].join(', ')}" )
      s << (depense[:pourquoi] ? " (#{depense[:pourquoi]})" : '')
      s << "\n"
    end
    return s
  end

end


class Matrix
  # Add to Matrix syntax :
  # matrix[i,j] = x
  def []=(i,j,x)
    @rows[i][j]=x
  end

  def to_s
    @rows.collect{ |row|
      "[" + row.collect{|e| e.to_s}.join(", ") + "]\n"
    }.join("")
  end
end
