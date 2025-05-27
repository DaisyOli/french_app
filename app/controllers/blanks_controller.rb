class BlanksController < ApplicationController
  before_action :set_fill_blank
  before_action :set_blank, only: [:update]

  def update
    respond_to do |format|
      if @blank.update(blank_params)
        format.html { redirect_to activity_path(@fill_blank.activity, scroll_to: "fill-blank-#{@fill_blank.id}"), notice: 'Resposta da lacuna atualizada com sucesso!' }
      else
        format.html { redirect_to activity_path(@fill_blank.activity), alert: 'Não foi possível atualizar a resposta da lacuna.' }
      end
    end
  end

  private
    def set_fill_blank
      @fill_blank = FillBlank.find(params[:fill_blank_id])
    end

    def set_blank
      @blank = @fill_blank.blanks.find(params[:id])
    end

    def blank_params
      params.require(:blank).permit(:correct_answer)
    end
end
