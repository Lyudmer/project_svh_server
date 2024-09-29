using System.Text;

namespace ServerSVH.Core.Models
{
    public class StatusGraph
    {
        private StatusGraph(int oldSt, int newSt)
        {
            OldSt = oldSt;
            NewSt = newSt;
        }
        public int OldSt { get; set; }
        public int NewSt { get; set; }
        public static StatusGraph Create(int oldSt, int newSt)
        {
            return new StatusGraph(oldSt, newSt);

        }
    }

}
