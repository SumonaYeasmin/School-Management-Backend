# ==============================================================================
# মাল্টি-স্টেজ ডকারফাইল (Multi-stage Dockerfile)
# ==============================================================================

# ১. বেইজ স্টেজ
FROM node:22-alpine AS base
WORKDIR /usr/src/app
RUN apk add --no-cache openssl

# ২. ডেভেলপমেন্ট স্টেজ (হট-রিলোড ও লোকাল ডেভ মোডের জন্য)
FROM base AS development
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "run", "start:dev"]

# ৩. বিল্ডার স্টেজ (TypeScript কম্পাইল করে dist তৈরি)
FROM base AS builder
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# ৪. প্রোডাকশন স্টেজ (লাইটওয়েট ও অপ্টিমাইজড ইমেজ)
FROM base AS production
ENV NODE_ENV=production
COPY package*.json ./
RUN npm install --omit=dev
COPY --from=builder /usr/src/app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/main.js"]

