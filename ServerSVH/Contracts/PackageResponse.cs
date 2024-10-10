namespace ServerSVH.Contracts
{
    public record PackageResponse
    (
        int Pid,
        Guid UserId,
        DateTime CreateDate,
        DateTime ModifyDate,
        Guid UUID,
        int StatusId
    );
}
