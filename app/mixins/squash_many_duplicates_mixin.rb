module SquashManyDuplicatesMixin
  def self.included(mixee)
    mixee.class_eval do

      # POST /venues/squash_multiple_duplicates
      def squash_many_duplicates
        # Derive model class from controller name
        model_class = self.controller_name.singularize.titleize.constantize

        master = model_class.find_by_id(params[:master_id])
        duplicate_ids = params.keys.grep(/^duplicate_id_\d+$/){|t| params[t].to_i}
        duplicates = model_class.where(id: duplicate_ids)
        singular = model_class.name.singularize.downcase
        plural = model_class.name.pluralize.downcase

        if master.nil?
          flash[:failure] = "A master #{singular} must be selected."
        elsif duplicates.empty?
          flash[:failure] = "At least one duplicate #{singular} must be selected."
        elsif duplicates.include?(master)
          flash[:failure] = "The master #{singular} could not be squashed into itself."
        else
          squashed = model_class.squash(master: master, duplicates: duplicates)

          if squashed.size > 0
            message = "Squashed duplicate #{plural} #{squashed.map {|obj| obj.title}.inspect} into master #{master.id}."
            flash[:success] = flash[:success].nil? ? message : flash[:success] + message
          else
            message = "No duplicate #{plural} were squashed."
            flash[:failure] = flash[:failure].nil? ? message : flash[:failure] + message
          end
        end

        redirect_to :action => "duplicates", :type => params[:type]
      end

    end
  end
end
