namespace :currency do
  namespace :layer do
    desc "Cache fixer's currency rates"
    task cache: :environment do
      puts 'Currency::Fixer added to cache' if Currency::Layer.cache
    end

    desc "Cache fixer's currency rates"
    task clear: :environment do
      puts 'Currency::Fixer removed from cache' if Currency::Layer.clear_cache
    end
  end
end
