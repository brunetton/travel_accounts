# -*- encoding : utf-8 -*-

require_relative 'depenses'
require_relative 'resultat'


class Array
  def sum
    self.inject{|sum,x| sum + x }
  end
end


class Float
  def almost_zero?(precision)
    return self.abs < precision
  end
end


class Comptes

  def self.affichage_probleme(oo_reader)
    puts "Dépenses :" + (oo_reader.nb_tableaux_parse > 1 ? " (#{oo_reader.nb_tableaux_parse} sous tableaux trouvés)" : '')
    puts oo_reader.depenses
  end


  # Renvoie un Hash représentant la balance des dépenses.
  # Exemple : {"E"=>-11, "D"=>7, "C"=>-5, "B"=>7, "A"=>2}
  def self.calcul_balance(depenses, precision)
    participants = depenses.participants
    balance = Hash[participants.map{|p| [p, 0.0]}]  # {'first person' => 0, 'second person' => 0, ...}
    for depense in depenses.depenses
      # On soustrait la totalité à la balance du payeur
      balance[depense[:qui]] -= depense[:combien]
      pour_qui = depense[:pour_qui] == :tous ? participants : depense[:pour_qui]
      # on ajoute à tous les receveurs une part de dette (payeur éventuellement compris)
      part = depense[:combien] / Float(pour_qui.size)
      for receveur in pour_qui
        balance[receveur] += part
      end
      # Ensure balance sum is zero
      raise 'Balance is not balanced !' unless balance.to_a.map{|e| e[1]}.sum.almost_zero?(precision)
    end
    return balance
  end


  # Renvoie un objet Resultat contenant les transactions nécessaires pour résoudre la balance donnée en paramètres
  #   - payers_order: ordre dans lequel les personnes préfèrent effectuer des transactions
  #     (le premier de la liste va devoir faire plus de transactions que le dernier)
  def self.calcul_dettes(depenses, payers_order=nil, precision=0.001)
    # Checking param type
    if depenses.class == Depenses
      # nop
    elsif depenses.class == OoReader
      depenses = depenses.depenses
    else
      raise "type de donnée inconnue pour les dépenses : #{depenses.class}"
    end
    if payers_order
      raise "payers_order must be an Array. Received : #{payers_order.class}" unless payers_order.is_a?(Array)
      raise "payers_order must be an non empty Array. Received : #{payers_order}" if payers_order.empty?
      # Check for names
      for name in payers_order
        raise "payers_order must containts only Strings. Received #{name} witch is a #{name.class}" unless name.is_a?(String)
        raise "Unknown name '#{name}' in payers_order (#{payers_order}). Valid names are #{depenses.participants}" \
              unless depenses.participants.include?(name)
      end
    end

    balance = self.calcul_balance(depenses, precision)
    balance.freeze

    # Séparation des positifs et négatifs de la balance
    pos = balance.select{|k,v| v > 0}
    neg = balance.select{|k,v| v < 0}

    # Dans le cas où aucun ordre de préférence n'est donné, on procède dans l'ordre arbitraire du montant des dettes
    if not payers_order
      payers_order = Hash[pos.sort_by{|k,v| v}].keys
    end

    # Initialisation de la matrice résultat
    dettes = Matrix.zero(depenses.nombre_participants)

    # itération sur les personnes qui doivent rembourser, dans l'ordre inverse des préférences du nombre de transactions,
    # auxquelles on ajoute les éventuels soldes positifs restants (qui ne feraient pas partie de payers_order)
    payers_to_add = pos.keys - payers_order  # Noms des payeurs éventuellement non inclus dans payers_order
    payers_to_treat_in_order = ((payers_order & pos.keys) + payers_to_add).reverse
    for payer in payers_to_treat_in_order
      while not pos[payer].almost_zero?(precision)
        # le solde de ce payeur n'est toujours pas 0; on continue à le faire rembouser
        # le receveur choisi est celui qui a le solde le plus négatif
        receiver_infos = neg.min_by{|k,v| v}  # ["Bruno", -7]
        receiver = receiver_infos[0]
        # montant de la transaction : le plus grand possible
        amount = [-receiver_infos[1], pos[payer]].min
        pos[payer] -= amount
        neg[receiver] += amount
        # Mise à jour de la matrice résultat
        dettes[depenses.index_participant(payer), depenses.index_participant(receiver)] += amount
      end
    end
    raise "Erreur: il reste des dépenses non remboursées !" if pos.merge(neg).find{|k,v| not v.almost_zero?(precision)}
    return Resultat.new(depenses.participants, dettes)
  end


  def self.affichage_verification_resultat(oo_reader, resultat, precision = 0.01)
    def self.payeurs(depenses)
      payeurs = []
      depenses.each do |depense|
        payeurs << depenses.index_participant(depense[:qui])
      end
      return payeurs.uniq
    end

    def self.calculer_gain_theorique(index_participant, depenses)
      messages_positifs = []
      total = 0.0
      prenom = depenses.participants.at(index_participant)
      messages_negatifs = []
      # dépenses communes
      depenses.each do |depense|
        total_depense = depense[:combien]
        message = ''
        message_fin = ''
        if depense[:qui] == prenom
          # dépense faite par lui
          if depense[:pour_qui] == :tous or depense[:pour_qui].include?(prenom)
            nb_concernes = depense[:pour_qui] == :tous ? depenses.nombre_participants : depense[:pour_qui].size
            n = total_depense.to_f * (nb_concernes - 1.0) / nb_concernes.to_f
            message = "#{formatter_decimal(n)} (#{nb_concernes-1}/#{nb_concernes} de #{formatter_decimal(total_depense)}"
            message_fin = ')';
          else
            n = total_depense.to_f
            message = formatter_decimal(n)
            message_fin = '';
          end
        elsif depense[:pour_qui] == :tous or depense[:pour_qui].include? prenom
          # dépense faite par un autre pour lui
          nb_concernes = depense[:pour_qui] == :tous ? depenses.nombre_participants : depense[:pour_qui].size
          n = - total_depense.to_f / nb_concernes.to_f
          if nb_concernes > 1
            message = "#{formatter_decimal(-n)} (1/#{nb_concernes} de #{formatter_decimal(total_depense)}"
          else
            message = "#{formatter_decimal(-n)} (#{formatter_decimal(total_depense)}"
          end
          message_fin = ')';
        else
          next
        end
        message += " pour #{depense[:pourquoi]}" + message_fin if depense[:pourquoi]
        if n < 0
          messages_negatifs << message
        else
          messages_positifs << message
        end
        total += n
      end
      return {
        :total => total,
        :detail => messages_positifs.join(' + ') + ' - ' + messages_negatifs.join(' - ')
      }
    end

    def self.remboursement_effectif(index_participant, resultat)
      total = 0.0
      messages_positifs = []
      messages_negatifs = []
      # ce qu'on lui donne
      resultat.matrice.column(index_participant).to_a.each do |n|
        next if n == 0
        messages_positifs << formatter_decimal(n)
        total += n
      end
      # ce qu'il donne
      resultat.matrice.row(index_participant).to_a.each do |n|
        next if n == 0
        messages_negatifs << formatter_decimal(n)
        total -= n
      end
      return {
        :total => total,
        :detail => messages_positifs.join(' + ') + (messages_negatifs.empty? ? '' : ' - ' + messages_negatifs.join(' - '))
      }
    end

    depenses = oo_reader.depenses
    verifs = []
    payeurs(depenses).each do |index_participant|
      remboursement_effectif = remboursement_effectif(index_participant, resultat)
      remboursement_theorique = calculer_gain_theorique(index_participant, depenses)
      verifs << {
        :qui => depenses.participants.at(index_participant),
        :remboursement_theorique => remboursement_theorique[:total],
        :message_theorique => remboursement_theorique[:detail],
        :remboursement_effectif => remboursement_effectif[:total],
        :message_effectif => remboursement_effectif[:detail],
      }
    end
    verifs.each do |v|
      puts "  #{v[:qui]}:"
      puts "    Théorique : #{formatter_decimal(v[:remboursement_theorique])} = #{v[:message_theorique]}"
      puts "    Effectif : #{formatter_decimal(v[:remboursement_effectif])} = #{v[:message_effectif]}"
      ok = (v[:remboursement_effectif] - v[:remboursement_theorique]).abs < precision
      puts "    Vérification : #{ok ? 'ok' : "##### ERREUR #### (#{v[:remboursement_effectif] - v[:remboursement_theorique]})"}"
      puts
    end
  end


  protected


  def self.formatter_decimal(n)
    return "%.2f" % n
  end


end
