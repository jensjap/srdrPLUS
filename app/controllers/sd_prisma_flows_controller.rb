class SdPrismaFlowsController < ApplicationController
  def update
    sd_prisma_flow = SdPrismaFlow.find_by(id: params[:id])
    authorize(sd_prisma_flow)
    sd_prisma_flow.update(sd_prisma_flow_params)
    render json: sd_prisma_flow.as_json, status: 200
  end

  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_prisma_flow = sd_meta_datum.sd_prisma_flows.create(sd_prisma_flow_params)
    render json: { id: sd_prisma_flow.id, name: sd_prisma_flow.name, sd_meta_data_figures: [] }, status: 200
  end

  def destroy
    sd_prisma_flow = SdPrismaFlow.find_by(id: params[:id])
    authorize(sd_prisma_flow)
    sd_prisma_flow.destroy
    render json: sd_prisma_flow.as_json, status: 200
  end

  private

  def sd_prisma_flow_params
    params.permit(:name)
  end
end
