# frozen_string_literal: true

module Views
  module Reviews
    class New < Views::Base
      def initialize(review:, job_request:, reviewee:, is_provider_context: false)
        @review = review
        @job_request = job_request
        @reviewee = reviewee
        @is_provider_context = is_provider_context
      end

      def view_template
        render Components::Shared::PageHeader.new(
          title: "Leave a Review",
          back_path: back_path
        )

        Card do
          CardHeader do
            div(class: "flex items-center gap-4") do
              Avatar(size: :lg) do
                if @reviewee.avatar_url.present?
                  AvatarImage(src: @reviewee.avatar_url, alt: @reviewee.display_name)
                end
                AvatarFallback { reviewee_initials }
              end

              div do
                CardTitle { @reviewee.display_name }
                CardDescription { @job_request.service_type.name }
              end
            end
          end

          CardContent do
            form(action: form_path, method: "post", class: "space-y-6") do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

              if @review.errors.any?
                Alert(variant: :destructive, class: "mb-4") do
                  AlertTitle { "Please fix the following errors:" }
                  AlertDescription do
                    ul(class: "list-disc list-inside") do
                      @review.errors.full_messages.each do |msg|
                        li { msg }
                      end
                    end
                  end
                end
              end

              FormField do
                FormFieldLabel { "Rating" }
                render Components::Reviews::StarRatingInput.new(
                  name: "review[rating]",
                  value: @review.rating || 0
                )
              end

              FormField do
                FormFieldLabel(for: "review_comment") { "Comment (optional)" }
                Textarea(
                  id: "review_comment",
                  name: "review[comment]",
                  rows: 4,
                  placeholder: "Share your experience..."
                ) { @review.comment }
              end

              Button(type: "submit", variant: :primary, class: "w-full") do
                "Submit Review"
              end
            end
          end
        end
      end

      private

      def back_path
        if @is_provider_context
          provider_my_job_path(@job_request)
        else
          job_request_path(@job_request)
        end
      end

      def form_path
        if @is_provider_context
          provider_my_job_review_path(@job_request)
        else
          job_request_review_path(@job_request)
        end
      end

      def reviewee_initials
        first = @reviewee.first_name&.first&.upcase || ""
        last = @reviewee.last_name&.first&.upcase || ""
        initials = "#{first}#{last}"
        initials.present? ? initials : @reviewee.email_address&.first&.upcase || "U"
      end
    end
  end
end
