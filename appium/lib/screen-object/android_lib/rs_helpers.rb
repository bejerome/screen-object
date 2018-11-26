module Android
  module RsHelpers

    class Hash
      def return_key_values(key, object=self, found=[])
        if object.respond_to?(:key?) && object.key?(key)
          found << object[key]
        end
        if object.is_a? Enumerable
          found << object.collect { |*a| return_key_values(key, a.last) }
        end
        found.flatten.compact
      end

    end

    class String
      def is_fl?
        self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
      end
    end

    class Array
      def compare(other)
        if sort == other.sort
          log_info("#{self.to_s} matches #{other.to_s}")
        else
          log_error("#{self.to_s} filed to match #{other.to_s}")
        end
      end

    end


    module ScreenWrapper

      class RetireSmart

        def initialize(driver=$driver)
          @driver = driver
        end

        def user_agreement_screen
          @user_agreement_screen ||= AgreementScreen.new($driver)
        end

        def login_screen
          @login_screen ||= Login.new($driver)
        end

        # def identity_verification_screen
        #   @identity_verification_screen =page(IdentityVerificationScreen)
        # end

        def challenge_question_screen
          @challenge_question_screen ||= ChallengeQuestionsScreen.new($driver)
        end

        # def select_account_screen
        #   @select_account_screen = page(SelectAccountScreen)
        # end
        #
        def save_username_screen
          @save_username_screen ||= SaveUsernameScreen.new($driver)
        end

        def select_plan_screen
          @select_plan_screen = SelectPlanScreen.new($driver)
        end

        def dashboard_screen
          @dashboard_screen ||= DashboardScreen.new($driver)
        end
        #
        # def ssn_input_screen
        #   @ssn_input_screen = page(SsnInputScreen)
        # end
        #
        def manage_screen
          @manage_screen ||= ManageScreen.new($driver)
        end
        #
        def contribution_screen
          @contribution_screen ||= ContributionScreen.new($driver)
        end
        #
        # def contribution_change_screen
        #   @contribution_change_screen = page(ContributionChangeScreen)
        # end
        #
        # def contribution_review_screen
        #   @contribution_review_screen = page(ContributionReviewScreen)
        # end
        #
        # def current_loans_screen
        #   @current_loans_screen = page(CurrentLoansScreen)
        # end
        #
        # def delivery_screen
        #   @delivery_screen = page(DeliveryPreferenceScreen)
        # end
        #
        def loans_screen
          @loans_screen ||= LoanScreen.new($driver)
        end

        # def payoff_screen
        #   @payoff_screen = page(PayoffScreen)
        # end
        #
        def investment_screen
          @investment_screen ||= InvestmentScreen.new($driver)
        end
        #
        # def personal_information_screen
        #   @personal_information_screen = page(PersonalInformation)
        # end
        #
        def more_screen
          @more_screen ||= MoreScreen.new($driver)
        end
        #
        # def change_login_screen
        #   @change_login_screen = page(ChangeLoginScreen)
        # end
        #
        # def change_pin_screen
        #   @change_pin_screen = page(ChangePinScreen)
        # end
        #
        # def vested_balance_screen
        #   @vested_balance_screen = page(VestedBalanceScreen)
        # end
        # def helpers
        #   @helpers = ScreenHelpers.new
        # end
        # def statement_screen
        #   @statement_screen = page(StatementScreen)
        # end
        # def tax_form_screen
        #   @tax_form_screen = page(TaxFormScreen)
        # end

      end

    end



    def routes(options={})
      options.each do |pageObject, method|
        page_cls = Object.const_get(pageObject)
        page(page_cls).await
        page(page_cls).send("#{method}")
        wait_for_element_does_not_exist("* id:'progressBar'")
      end

    end

  end
end