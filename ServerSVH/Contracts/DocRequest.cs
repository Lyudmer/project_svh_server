using System.ComponentModel.DataAnnotations;

namespace ServerSVH.Contracts
{
    public record DocRequest
    (
        [Required]
        int Id

    );

}
