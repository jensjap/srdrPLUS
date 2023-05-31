# == Schema Information
#
# Table name: ml_models
#
#  id         :bigint           not null, primary key
#  timestamp  :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MlModel < ApplicationRecord
  has_many :ml_models_projects
  has_many :projects, through: :ml_models_projects
  has_many :model_performances
  has_many :model_predictions

  validates :timestamp, presence: true

  def confusion_matrix
    tp = model_performances.where("label = ? AND score >= ?", 1, 0.5).count
    fp = model_performances.where("label = ? AND score >= ?", 0, 0.5).count
    tn = model_performances.where("label = ? AND score < ?", 0, 0.5).count
    fn = model_performances.where("label = ? AND score < ?", 1, 0.5).count

    { TP: tp, TN: tn, FP: fp, FN: fn }
  end

  def precision
    matrix = confusion_matrix
    if matrix[:TP] + matrix[:FP] == 0
      return nil
    end

    matrix[:TP].to_f / (matrix[:TP] + matrix[:FP])
  end

  def recall
    matrix = confusion_matrix
    if matrix[:TP] + matrix[:FN] == 0
      return nil
    end

    matrix[:TP].to_f / (matrix[:TP] + matrix[:FN])
  end

  def f1_score
    prec = precision
    rec = recall

    if prec.nil? || rec.nil? || prec + rec == 0
      return nil
    end

    2 * (prec * rec) / (prec + rec)
  end

  def accuracy_score
    matrix = confusion_matrix
    if matrix[:TP] + matrix[:TN] + matrix[:FP] + matrix[:FN] == 0
      return nil
    end

    (matrix[:TP] + matrix[:TN]).to_f / (matrix[:TP] + matrix[:TN] + matrix[:FP] + matrix[:FN])
  end
end
