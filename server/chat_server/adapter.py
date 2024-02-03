
from fastchat.model.model_chatglm import generate_stream_chatglm
from fastchat.model.model_codet5p import generate_stream_codet5p
from fastchat.model.model_falcon import generate_stream_falcon
import os
import torch
from typing import Dict
# Check an environment variable to check if we should be sharing Peft model
# weights.  When false we treat all Peft models as separate.
peft_share_base_weights = (
    os.environ.get("PEFT_SHARE_BASE_WEIGHTS", "false").lower() == "true"
)


def get_generate_stream_function(model: torch.nn.Module, model_path: str):
    """Get the generate_stream function for inference."""
    from inference import generate_stream

    model_type = str(type(model)).lower()
    is_chatglm = "chatglm" in model_type
    is_falcon = "rwforcausallm" in model_type
    is_codet5p = "codet5p" in model_type
    is_peft = "peft" in model_type

    if is_chatglm:
        return generate_stream_chatglm
    elif is_falcon:
        return generate_stream_falcon
    elif is_codet5p:
        return generate_stream_codet5p
    elif peft_share_base_weights and is_peft:
        # Return a curried stream function that loads the right adapter
        # according to the model_name available in this context.  This ensures
        # the right weights are available.
        @torch.inference_mode()
        def generate_stream_peft(
            model,
            tokenizer,
            params: Dict,
            device: str,
            context_len: int,
            stream_interval: int = 2,
            judge_sent_end: bool = False,
        ):
            model.set_adapter(model_path)
            for x in generate_stream(
                model,
                tokenizer,
                params,
                device,
                context_len,
                stream_interval,
                judge_sent_end,
            ):
                yield x

        return generate_stream_peft
    else:
        return generate_stream