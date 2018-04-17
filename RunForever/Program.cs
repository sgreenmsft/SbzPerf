using System;

namespace RunForever
{
    class Program
    {
        static void Main(string[] args)
        {
            int counter = 0;
            while (true)
            {
                Console.WriteLine($"I've been running for {counter++} minutes.");
                System.Threading.Thread.Sleep(TimeSpan.FromMinutes(1));
            }
        }
    }
}
