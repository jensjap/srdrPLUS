class SdJournalArticleUrlsController < ApplicationController
  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_journal_article_url = SdJournalArticleUrl.create(name: params[:name], sd_meta_datum:)
    render json: sd_journal_article_url.as_json, status: 200
  end

  def update
    sd_journal_article_url = SdJournalArticleUrl.find_by(id: params[:id])
    authorize(sd_journal_article_url)
    sd_journal_article_url.update(name: params[:name])
    render json: sd_journal_article_url.as_json, status: 200
  end

  def destroy
    sd_journal_article_url = SdJournalArticleUrl.find_by(id: params[:id])
    authorize(sd_journal_article_url)
    sd_journal_article_url.destroy
    render json: { id: sd_journal_article_url.id }, status: 200
  end
end
