# frozen_string_literal: true

module CoEditPDF
  # Get a pdf and check its policy
  class GetPdfQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that pdf'
      end
    end

    # Error for cannot find a pdf
    class NotFoundError < StandardError
      def message
        'We could not find that pdf'
      end
    end

    def self.call(auth:, pdf:)
      raise NotFoundError unless pdf

      policy = PdfPolicy.new(auth[:account], pdf, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      pdf.full_details.merge(policies: policy.summary)
    end
  end
end
