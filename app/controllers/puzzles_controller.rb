class PuzzlesController < ApplicationController
  respond_to :html

  def index
    @puzzles = Puzzle.published(current_user).order("created_at").all

    respond_with(@puzzles)
  end

  def tag
    @puzzles = Puzzle.published(current_user).order("created_at").
                tagged_with(params[:tag])

    respond_with(@puzzles) do |format|
      format.html { render :index }
    end
  end

  def show
    @puzzle = Puzzle.find(params[:id])

    unless @puzzle.published?
      if current_user.nil? || !(current_user.draft_access || current_user.admin)
        flash[:error] = "Sorry, this puzzle hasn't been published yet."
        redirect_to root_path
      end
    end

    respond_with(@puzzle)
  end

  def attachments
    attachment = Attachment.where("file_name ILIKE ? AND puzzle_id = ?",
      [params[:file], params[:format]].compact.join("."), params[:id]).first

    if attachment
      send_data(File.binread(attachment.file_path))
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
