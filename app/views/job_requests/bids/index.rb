# frozen_string_literal: true

module Views
  module JobRequests
    module Bids
      class Index < Views::Base
        def initialize(job_request:, bids:)
          @job_request = job_request
          @bids = bids
        end

        def view_template
          render Components::Shared::PageHeader.new(
            title: "Bids",
            subtitle: "#{@bids.count} #{'bid'.pluralize(@bids.count)} received",
            back_path: job_request_path(@job_request)
          )

          # Job summary card
          Card(class: "mb-6") do
            CardHeader do
              div(class: "flex items-center justify-between") do
                div do
                  CardTitle { @job_request.service_type.name }
                  CardDescription { @job_request.property&.display_address }
                end
                render Components::JobRequests::JobStatusBadge.new(status: @job_request.status)
              end
            end
          end

          if @bids.any?
            div(class: "space-y-4") do
              @bids.each do |bid|
                render Components::Bids::BidCard.new(
                  bid: bid,
                  job_request: @job_request,
                  show_actions: @job_request.open_for_bids?
                )
              end
            end
          else
            render Components::Shared::EmptyState.new(
              icon: :inbox,
              title: "No bids yet",
              description: "Providers will start bidding on your job request soon."
            )
          end
        end
      end
    end
  end
end
