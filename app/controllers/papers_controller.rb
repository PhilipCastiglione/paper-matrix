class PapersController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  before_action :set_paper, only: %i[ show edit update destroy fetch_source_file generate_auto_summary ]

  # GET /papers or /papers.json
  def index
    @papers = Paper.all
  end

  # GET /papers/1 or /papers/1.json
  def show
  end

  # GET /papers/new
  def new
    @paper = Paper.new
  end

  # GET /papers/1/edit
  def edit
  end

  # POST /papers or /papers.json
  def create
    @paper = Paper.new(paper_params)

    respond_to do |format|
      if @paper.save
        format.html { redirect_to @paper, notice: "Paper was successfully created." }
        format.json { render :show, status: :created, location: @paper }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @paper.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /papers/1 or /papers/1.json
  def update
    respond_to do |format|
      if @paper.update(paper_params)
        format.html { redirect_to @paper, notice: "Paper was successfully updated." }
        format.json { render :show, status: :ok, location: @paper }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @paper.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /papers/1/fetch_source_file
  def fetch_source_file
    respond_to do |format|
      if @paper.fetch_source_file_from_url!
        format.html { redirect_to @paper, notice: "Source file was successfully fetched." }
        format.json { render :show, status: :ok, location: @paper }
      else
        format.html { redirect_to @paper, alert: @paper.errors.full_messages.join(", ") }
        format.json { render json: @paper.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /papers/1/generate_auto_summary
  def generate_auto_summary
    respond_to do |format|
      if @paper.generate_auto_summary!
        format.html { redirect_to @paper }
        format.json { render :show, status: :ok, location: @paper }
      else
        format.html { redirect_to @paper, alert: @paper.errors.full_messages.join(", ") }
        format.json { render json: @paper.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /papers/1 or /papers/1.json
  def destroy
    @paper.destroy!

    respond_to do |format|
      format.html { redirect_to papers_path, status: :see_other, notice: "Paper was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_paper
    @paper = Paper.find(params.expect(:id))
  end

  def paper_params
    params.expect(paper: [ :url, :title, :read, :authors, :year, :auto_summary, :notes, :source_file ])
  end
end
