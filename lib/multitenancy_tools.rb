require 'multitenancy_tools/version'
require 'multitenancy_tools/errors'
require 'multitenancy_tools/dump_cleaner'
require 'multitenancy_tools/dump/data_only'
require 'multitenancy_tools/dump/schema_only'
require 'multitenancy_tools/schema_dumper'
require 'multitenancy_tools/schema_creator'
require 'multitenancy_tools/table_dumper'
require 'multitenancy_tools/schema_switcher'
require 'multitenancy_tools/schema_destroyer'
require 'multitenancy_tools/functions_dumper'
require 'multitenancy_tools/schema_migrator'
require 'multitenancy_tools/extensions_dumper'

module MultitenancyTools
  # Creates a new schema using the SQL file as template. This SQL file can be
  # generated by {SchemaDumper}.
  #
  # @see SchemaCreator
  # @see SchemaDumper
  # @param name [String] schema name
  # @param sql_file [String] absolute path to the SQL template
  # @param connection [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter] connection adapter
  def self.create(name, sql_file, connection = ActiveRecord::Base.connection)
    SchemaCreator.new(name, connection).create_from_file(sql_file)
  end

  # Drops the schema from the database.
  #
  # @see SchemaDestroyer
  # @param name [String] schema name
  # @param connection [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter] connection adapter
  def self.destroy(name, connection = ActiveRecord::Base.connection)
    SchemaDestroyer.new(name, connection).destroy
  end

  # Uses the passed schema as the scope for all queries triggered by the block.
  #
  # @see SchemaSwitcher
  # @param schema [String] schema name
  # @param connection [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter] connection adapter
  # @yield The block that must be executed using the schema as scope
  def self.using(schema, connection = ActiveRecord::Base.connection, &block)
    SchemaSwitcher.new(schema, connection).run(&block)
  end

  # Generates a SQL dump of the schema. Requires pg_dump.
  #
  # @see SchemaDumper
  # @param database [String]
  # @param schema [String]
  # @param file [String]
  def self.dump_schema(database, schema, file, **args)
    SchemaDumper.new(database, schema).dump_to(file, **args)
  end

  # Generates a SQL dump of the table. Requires pg_dump.
  #
  # @see TableDumper
  # @param database [String]
  # @param schema [String]
  # @param table [String]
  # @param file [String]
  def self.dump_table(database, schema, table, file, **args)
    TableDumper.new(database, schema, table).dump_to(file, **args)
  end

  # Generates a SQL dump of all extensions enabled on the database.
  #
  # @see ExtensionsDumper
  # @param file [String]
  # @param connection [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter] connection adapter
  def self.dump_extensions(file, connection = ActiveRecord::Base.connection, **args)
    ExtensionsDumper.new(connection).dump_to(file, **args)
  end
end
