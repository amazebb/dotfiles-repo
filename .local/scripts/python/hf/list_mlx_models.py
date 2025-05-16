from huggingface_hub import list_models

# Filter models by the mlx-community organization
models = list_models(author="mlx-community")

# Sort by created_at (descending) and id (ascending), handle None created_at
for model in sorted(
    models,
    key=lambda x: (-(x.created_at.timestamp() if x.created_at else float("inf")), x.id),
):
    print(
        f"{model.id:<50} {(model.created_at.strftime('%Y-%m-%d') if model.created_at else 'Unknown')}"
    )
