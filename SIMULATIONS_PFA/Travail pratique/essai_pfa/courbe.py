import matplotlib.pyplot as plt

# File path
file_path = "fichier_2.txt"

# Read temperature values
temperatures = []

with open(file_path, "r") as file:
    for line1 in file:
        # Remove whitespace and possible °C
        value = line1.strip().replace("°C", "")
        
        if value:  # avoid empty lines
            temperatures.append(float(value))

# Create time axis (2 seconds interval)
time = [i  for i in range(len(temperatures))]

# Plot
plt.figure()
plt.plot(time, temperatures)

plt.xlabel("temps (seconds)")
plt.ylabel("Temperature (°C)")
plt.title("Courbe de Temperature en fonction du temps ")

plt.grid()

plt.show()