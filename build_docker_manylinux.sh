# Build an Image
# ------------------------------------------------
docker build -t my-image .

# Run container
docker run --name my-container my-image

# Copy file from the container to the host
# ------------------------------------------------
docker cp my-container:/root/easyclimate-backend/wheelhouse ./wheelhouse
# docker cp my-container:/root/easyclimate-backend/dist ./dist

# Delete the container and image
# ------------------------------------------------
docker rm my-container
docker rmi my-image
cp ./wheelhouse/*.whl ./dist
rm -r ./wheelhouse
