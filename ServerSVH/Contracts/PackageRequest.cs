using System.ComponentModel.DataAnnotations;

namespace ServerSVH.Contracts
{
    public record PackageRequest
 (
     [Required]
        int Pid

 );

}
