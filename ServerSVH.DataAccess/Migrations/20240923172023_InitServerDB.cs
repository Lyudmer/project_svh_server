using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace ServerSVH.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class InitServerDB : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DocRecordEntity",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DocId = table.Column<Guid>(type: "uuid", nullable: false),
                    DocText = table.Column<string>(type: "text", nullable: false),
                    CreateDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ModifyDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DocRecordEntity", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "packages",
                columns: table => new
                {
                    pid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    create_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()"),
                    modify_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    uuid = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    status = table.Column<int>(type: "integer", nullable: false, defaultValue: 0)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_packages", x => x.pid);
                });

            migrationBuilder.CreateTable(
                name: "pkg_status_graph",
                columns: table => new
                {
                    oldst = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    newst = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_pkg_status_graph", x => x.oldst);
                });

            migrationBuilder.CreateTable(
                name: "documents",
                columns: table => new
                {
                    did = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    size_doc = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    idmd5 = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    idsha256 = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    create_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()"),
                    modify_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    pid = table.Column<long>(type: "bigint", nullable: false),
                    docid = table.Column<Guid>(type: "uuid", nullable: false),
                    DocRecordId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_documents", x => x.did);
                    table.ForeignKey(
                        name: "FK_documents_DocRecordEntity_DocRecordId",
                        column: x => x.DocRecordId,
                        principalTable: "DocRecordEntity",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_documents_packages_pid",
                        column: x => x.pid,
                        principalTable: "packages",
                        principalColumn: "pid",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_documents_DocRecordId",
                table: "documents",
                column: "DocRecordId");

            migrationBuilder.CreateIndex(
                name: "IX_documents_pid",
                table: "documents",
                column: "pid");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "documents");

            migrationBuilder.DropTable(
                name: "pkg_status_graph");

            migrationBuilder.DropTable(
                name: "DocRecordEntity");

            migrationBuilder.DropTable(
                name: "packages");
        }
    }
}
