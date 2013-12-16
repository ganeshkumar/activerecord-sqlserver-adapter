module ActiveRecord
  module ConnectionAdapters
    module Sqlserver
      module CoreExt
        class ExplainSubscriber
          def call(*args)
            if queries = Thread.current[:available_queries_for_explain]
              payload = args.last
              queries << payload.values_at(:sql, :binds) unless ignore_sqlserver_payload?(payload)
            end
          end

          IGNORED_PAYLOADS = %w(SCHEMA EXPLAIN CACHE)
          SQLSERVER_EXPLAINED_SQLS = /(select|update|delete|insert)/i

          # TODO Need to modify the regex for the TSQL generated by this adapter so we can explain the proper sql statements
          def ignore_sqlserver_payload?(payload)
            payload[:exception] || IGNORED_PAYLOADS.include?(payload[:name]) || payload[:sql] !~ SQLSERVER_EXPLAINED_SQLS
          end

          ActiveSupport::Notifications.subscribe("sql.active_record", new)
        end
      end
    end
  end
end
