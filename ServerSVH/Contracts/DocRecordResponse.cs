namespace ServerSVH.Contracts
{
    record class DocRecordResponse
    (
        Guid Id,
        Guid DocId,
        string DocText,
        DateTime CreateDate,
        DateTime ModifyDate
     );
}
