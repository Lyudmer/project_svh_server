using System.ComponentModel.DataAnnotations;

namespace ServerSVH.Contracts
{
    public record LoadMessRequest(

      [Required]
        string Message
      );
}
