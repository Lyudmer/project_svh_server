using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace ServerSVH.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class UpdateServerDbIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_documents_DocRecordEntity_DocRecordId",
                table: "documents");

            migrationBuilder.DropTable(
                name: "DocRecordEntity");

            migrationBuilder.DropPrimaryKey(
                name: "PK_pkg_status_graph",
                table: "pkg_status_graph");

            migrationBuilder.DropIndex(
                name: "IX_documents_DocRecordId",
                table: "documents");

            migrationBuilder.DropColumn(
                name: "DocRecordId",
                table: "documents");

            migrationBuilder.AlterColumn<int>(
                name: "oldst",
                table: "pkg_status_graph",
                type: "integer",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer")
                .OldAnnotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AddColumn<string>(
                name: "DocType",
                table: "documents",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK_pkg_status_graph",
                table: "pkg_status_graph",
                columns: new[] { "oldst", "newst" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_pkg_status_graph",
                table: "pkg_status_graph");

            migrationBuilder.DropColumn(
                name: "DocType",
                table: "documents");

            migrationBuilder.AlterColumn<int>(
                name: "oldst",
                table: "pkg_status_graph",
                type: "integer",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer")
                .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AddColumn<Guid>(
                name: "DocRecordId",
                table: "documents",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_pkg_status_graph",
                table: "pkg_status_graph",
                column: "oldst");

            migrationBuilder.CreateTable(
                name: "DocRecordEntity",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CreateDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    DocId = table.Column<Guid>(type: "uuid", nullable: false),
                    DocText = table.Column<string>(type: "text", nullable: false),
                    ModifyDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DocRecordEntity", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_documents_DocRecordId",
                table: "documents",
                column: "DocRecordId");

            migrationBuilder.AddForeignKey(
                name: "FK_documents_DocRecordEntity_DocRecordId",
                table: "documents",
                column: "DocRecordId",
                principalTable: "DocRecordEntity",
                principalColumn: "Id");
        }
    }
}
