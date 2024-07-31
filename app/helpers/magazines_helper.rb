module MagazinesHelper
    # calcular el total de comentarios
    def total_comentarios_magazine(magazine)
        total_comentarios = 0
        magazine.hilos.each do |hilo|
          total_comentarios += hilo.comments.count
        end
        total_comentarios
      end
end
