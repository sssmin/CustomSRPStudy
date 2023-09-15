using UnityEngine;
using UnityEngine.Rendering;


[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public class CustomRPAsset : RenderPipelineAsset
{
    [SerializeField] private bool useDynamicBatching = true;
    [SerializeField] private bool useGPUInstancing = true;
    [SerializeField] private bool useSRPBatcher = true;
    
    protected override RenderPipeline CreatePipeline()
    {
        return new CustomRP(useDynamicBatching, useGPUInstancing, useSRPBatcher);
    }
}
