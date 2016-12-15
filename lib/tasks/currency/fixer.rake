namespace :currency do
  namespace :fixer do
    desc "Cache fixer's currency rates"
    task cache: :environment do
      puts 'Currency::Fixer added to cache' if Currency::Fixer.cache
    end

    desc "Cache fixer's currency rates"
    task clear: :environment do
      puts 'Currency::Fixer removed from cache' if Currency::Fixer.clear_cache
    end
  end
end
