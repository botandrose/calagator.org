class EventsController < ApplicationController
  # GET /events
  # GET /events.xml
  def index
    order = params[:order] || 'date'
    order = case order
            when 'date'
              'start_time'
            when 'name'
              'events.title, start_time'
            when 'venue'
              'venues.title, start_time'
            end
    
    @start_date = params[:date] ? Date.parse(params[:date][:start]) : Date.today
    @end_date = params[:date] ? Date.parse(params[:date][:end]) : Date.today + 6.months
    @events = params[:date] ? 
        Event.find_by_dates(@start_date, @end_date, order) : 
        Event.find_all_future_events(order)
        
    @page_title = "Events"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
      format.json { render :json => @events }
      format.ics { ical_export() }
      format.atom # index.atom.builder
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    @page_title = @event.title

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
      format.json { render :json => @event }
      format.ics { ical_export([@event]) }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
    @page_title = "Add an Event"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @page_title = "Editing '#{@event.title}'"
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        flash[:success] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:success] = 'Event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /venues/duplicates
  def duplicates
    params[:type] ||= 'title'
    type = params[:type] || 'any'
    type = ['all','any'].include?(type) ? type.to_sym : type.split(',')
    
    @events = Event.find_duplicates_by(type)
    @page_title = "Duplicate Event Squasher"
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @venues }
    end
  end
  
  # POST /events/squash_multiple_duplicates
  def squash_many_duplicates
    master_event_id = params[:master_event_id].to_i
    duplicate_event_ids = params.keys.grep(/^duplicate_event_id_\d+$/){|t| params[t].to_i}

    Event.squash(:master => master_event_id, :duplicates => duplicate_event_ids)

    flash[:success] = "Squashed duplicates #{duplicate_event_ids.inspect} into master #{master_event_id}"
    redirect_to :action => "duplicates"
  end

protected

  # export events to an iCalendar file
  def ical_export(events=nil)
    events = events || Event.find(:all)
    render(:text => Event.to_ical(events, :url_helper => lambda{|event| event_url(event)}), :mime_type => 'text/calendar')
  end

end
